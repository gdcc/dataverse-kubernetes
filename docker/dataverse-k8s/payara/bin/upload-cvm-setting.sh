#!/bin/bash
################################################################################
# This script is used to merge the existing CVMConf with the given cvm-setting
# in json format and upload it the server.
# It requires two parameters: the Dataverse URL and the URL or file location of
# the cvm-setting that want to add.
################################################################################
#Function for validate a json file
validateJson(){
    if jq -e . >/dev/null 2>&1 < $1; then
        echo "Parsed JSON successfully"
        return 0
    else
        echo "Failed to parse JSON"
        return 1
    fi
}

#Function check duplicate
checkDuplicateAci(){
for i in $1
    do
        for j in $2
        do
           if [[ $i == $j ]]; then
               echo "ERROR: >>> Duplicate aci found: $j"
               exit
           fi
    done
done
}

dir_tmp_name="generated"
if [ "${GENERATED_DIR}" ]; then
    dir_tmp_name="${GENERATED_DIR}"
fi

if [ -d "$dir_tmp_name" ]; then
#     echo "Removing $dir_tmp_name"
#     rm -rf "$dir_tmp_name"
    echo "$dir_tmp_name folder exist."
else
    mkdir -p $dir_tmp_name
fi

url="$1/api/admin/settings/:CVMConf";
echo "Retrieving setting from $url"
dvnCvmConfSetting=$(curl -Ls $url)
# echo $dvnCvmConfSetting
cvmConfStatus=$(echo $dvnCvmConfSetting| jq '. | select(.status == "OK")')
# echo $cvmConfStatus
if [[ "$cvmConfStatus" == "" ]]; then
    echo "$url NOT FOUND."
    #do something here, eq upload a new one.
    exit
else
    echo "Status is OK"
fi
#Get the element value of data.message
dvnCvmConf=$(echo $dvnCvmConfSetting | jq '.data.message')
# echo $dvnCvmConf
#Remove all \n and \"
dvnCvmConfClean=`echo $dvnCvmConf | sed 's/[\][n]//g' | sed 's/\\\//g' | sed 's:^.\(.*\).$:\1:'`
# echo $dvnCvmConfClean

#Validate $dvnCvmConfClean
echo "Validate the cvm-setting.json from Dataverse"
if validateJson $dir_tmp_name/cvm-setting.json; then echo 'cvm-setting.json is valid.'; else echo 'ERROR: cvm-setting.json is not valid.'; exit; fi

#Create a pretty-print json file
echo $dvnCvmConfClean | jq . > $dir_tmp_name/cvm-setting.json

#Get all aci's key
acis=$(echo $dvnCvmConfClean | jq '.[].aci')
# echo $acis

echo "Retrieving json from $2"
# inputJson=""
if [[ "$2" =~ ^http* ]]; then
    inputJsonFromUrl=$(curl -Ls $2)
    echo $inputJsonFromUrl > $dir_tmp_name/cvm-setting-from-url.json
    #Validate $inputJsonFromUrl
    if validateJson $dir_tmp_name/cvm-setting-from-url.json; then echo "$2 is valid"; else echo "ERROR: $2 is not valid."; exit; fi
    aciFromUrl=$(echo $inputJsonFromUrl | jq '.[].aci')
#     echo $aciFromUrl

    #TODO: Refactoring using function to prevent repeating code
    echo "Checking for any duplicate"
    checkDuplicateAci "$acis" "$aciFromUrl"

    echo "No duplicate found. Write the json from $2 to $dir_tmp_name/cvm-setting-from-url.json"
    echo "Write the combined json to cvm-setting-combined.json"
    jq -s '[.[][]]' $dir_tmp_name/cvm-setting.json $dir_tmp_name/cvm-setting-from-url.json > $dir_tmp_name/cvm-setting-combined.json
else
    #Validate $json from file
    if validateJson $2; then echo "$2 is valid"; else echo "ERROR: $2 is not valid."; exit; fi
    inputJsonFromFile=$(echo $(<$2))
    aciFromFile=$(echo $inputJsonFromFile | jq '.[].aci')
#     echo $aciFromFile
    echo "Checking for any duplicate"
    checkDuplicateAci "$acis" "$aciFromFile"
    echo "No duplicate found."
    echo "Write the combined json to cvm-setting-combined.json"
    jq -s '[.[][]]' $dir_tmp_name/cvm-setting.json $2 > $dir_tmp_name/cvm-setting-combined.json
fi

if validateJson $dir_tmp_name/cvm-setting-combined.json; then
    echo 'cvm-setting-combined.json is valid'
    echo "Uploading cvm-setting-combined.json"
        #Push to the server
        uploadedResult=$(curl -H "Content-Type: application/json" -X PUT --data-binary @$dir_tmp_name/cvm-setting-combined.json "$1/api/admin/settings/:CVMConf")
        echo $uploadedResult | jq .
else
    echo 'ERROR: cvm-setting-combined.json is not valid.'
    exit
fi

