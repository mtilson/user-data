#!/usr/bin/env bash

test -f "$1" || { echo "=== err: file passed as 1-st arg (\"$1\") doesn't exist"; exit -1 ; }
echo "=== log: sourcing file (\"$1\"): START"
source $1
echo "=== log: sourcing file (\"$1\"): DONE"

# ./maps_aws declares the following associative arrays
#   map_os_user
#   map_os_ssm
source ./maps_aws

tag_type=${tag_type:-mtilson/user-data}

aws ec2 describe-instances \
  --filters Name=tag:Type,Values=$tag_type Name=instance-state-name,Values=running \
  --query 'Reservations[].Instances[].{InstanceId:InstanceId, TAGS:Tags[?Key == `OS`].Value, IP:NetworkInterfaces[].Association.PublicIp}' | \
  jq -r '.[] | [.InstanceId, .TAGS[], .IP[]] | @csv' | tr -d '"' | \
  while read line ; do
    id=$(echo $line | cut -d"," -f1)
    os=$(echo $line | cut -d"," -f2 | cut -d"-" -f1)
    ip=$(echo $line | cut -d"," -f3)
    echo "InstanceID: $id: ${map_os_user[$os]}@$ip"
done
