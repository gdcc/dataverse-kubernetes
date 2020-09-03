#!/usr/bin/env python3

"""
(C) Copyright 2020 Forschungszentrum Jülich GmbH and others.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed
under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
CONDITIONS OF ANY KIND, either express or implied. See the License for the
specific language governing permissions and limitations under the License.

Contributors:

 - Oliver Bertuch

"""

from pykeepass import PyKeePass
import argparse, logging, traceback, getpass
logging.basicConfig(format='%(levelname)s: %(message)s', level=logging.DEBUG)

# initiate the parser
desc = "Read K8s secrets from KeepassX database and pipe to stdout for kubectl use.\n Simply pipe to \" | kubectl apply -f - \"."
parser = argparse.ArgumentParser(description = desc)

# add args
parser.add_argument("-k", "--keepassfile", help="path to KeepassX database file", required=True)
parser.add_argument("-g", "--group", help="name of group secrets are stored in.", required=True)
parser.add_argument("-p", "--password", help="database password. Should be given in prompt, not as argument for better security.")
parser.add_argument("-A", "--attribute", help="attribute of secret entry to read. Repeatable. Non-existing skipped silently. Defaults to \"secret\".", action="append")
parser.add_argument("-s", "--secret", help="secret entry name(s) in group. Repeatable. Non-existing skipped silently. Will read all entries in group if not given.", action="append")

# do the parsing
args = parser.parse_args()
password = args.password

try:
    # get password from stdin
    if password is None:
        password = getpass.getpass(prompt="Database password: ")

    # go load the file
    kp = PyKeePass(args.keepassfile, password=password)

    # get group
    group = kp.find_groups(name=args.group, first=True)
    if group is None:
        raise ValueError("Group \""+args.group+"\" not found in database.")

    # get entries
    entries = []
    # -> get all if no specific secret name(s) given
    if args.secret is None:
        entries = group.entries
    # -> get all from specified secret name(s)
    else:
        for secret in args.secret:
            result = kp.find_entries(title=secret, group=group, first=True)
            entries.append(result) if result is not None else []

    # now get values from the entries and print to stdout
    printed = 0
    if args.attribute is None:
        args.attribute = ["secret"]
    for entry in entries:
        for att in args.attribute:
            value = entry.get_custom_property(att)
            if value is not None:
                print(value)
                printed+=1

    # Log how many entries we found (stdout will be piped to kubectl...)
    logging.error("Processed "+str(printed)+" secrets.")

except FileNotFoundError as e:
    logging.error("Could not find file %s", args.keepassfile)
except Exception as e:
    logging.error(e)
    logging.debug(traceback.format_exc())
except (KeyboardInterrupt, SystemExit):
    exit
