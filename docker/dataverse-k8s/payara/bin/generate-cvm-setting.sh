#!/bin/bash
################################################################################
# This script is used to generate cvm-setting.json file
################################################################################
IFS=$'\t'
# Fail on any error
set -euo pipefail
if [ "${CVM_SERVER_NAME}" ]; then
    echo ${CVM_SERVER_NAME}
    echo ${CVM_SERVER_URL};
    svr_name=${CVM_SERVER_NAME};
    echo $svr_name;
    svr_url=${CVM_SERVER_URL};
    echo $svr_url;
    echo $1;
    jso_text='';
    template='{"aci":"ACI","source-name":"CVM_SERVER_NAME", "source-url":"CVM_SERVER_URL","vocabs":["VOC"],"keys": ["KV","KT","KU"]}';
    template=${template//CVM_SERVER_NAME/$svr_name};
    template=${template//CVM_SERVER_URL/$svr_url};
    echo $template;
    json_process="";
    json_element="";
    i=0;
    while read KEY VOC OTHERS; do
      if [[ "$json_process" == "" && "$KEY" == *-cv ]]; then
        json_element=${template//VOC/$VOC};
        json_element=${json_element//ACI/$KEY};
        json_process="create"
      elif [[ "$json_process" == "create" ]]; then
        case $KEY in
         *-vocabulary ) json_element=${json_element//KV/$KEY};;
         *-term ) json_element=${json_element//KT/$KEY};;
         *-url ) json_element=${json_element//KU/$KEY};
                json_process="finish";
                ((i=i+1));;
        esac
      fi
      if [[ "$json_process" == "finish" ]]; then
        json_process="";
        if [[ i -gt 1 ]]; then
            jso_text="$jso_text, $json_element";
        else
            jso_text="$jso_text $json_element";
        fi
      fi
    done < $1
    jso_text="[$jso_text]";
    echo $jso_text > $2;
fi