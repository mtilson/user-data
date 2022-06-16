#!/usr/bin/env bash

test -f "$1" || { echo "error: file passed as 1-st arg (\"$1\") doesn't exist"; exit -1 ; }
source $1
tag_type=${tag_type:-mtilson/user-data}
source ./os2user

aws ec2 describe-instances \
  --filters Name=tag:Type,Values=$tag_type Name=instance-state-name,Values=running \
  --query 'Reservations[].Instances[].{InstanceId:InstanceId, TAGS:Tags[?Key == `Name`].Value, IP:NetworkInterfaces[].Association.PublicIp}' | \
  jq -r '.[] | [.InstanceId, .TAGS[], .IP[]] | @csv' | tr -d '"' | \
  while read line ; do
    id=$(echo $line | cut -d"," -f1)
    os=$(echo $line | cut -d"," -f2 | cut -d"-" -f1)
    ip=$(echo $line | cut -d"," -f3)
    echo "InstanceID: $id: ${sshUsers[$os]}@$ip"
done
