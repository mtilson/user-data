#!/usr/bin/env bash

test -f "$1" || { echo "error: file passed as 1-st arg (\"$1\") doesn't exist"; exit -1 ; }
source $1
tag_type=${tag_type:-mtilson/user-data}

id_list=$(aws ec2 describe-instances \
  --filters Name=tag:Type,Values=$tag_type Name=instance-state-name,Values=running \
  --query "Reservations[].Instances[].InstanceId" \
  --output text)

for instance_id in $id_list ; do

  echo "Instance ID: $instance_id"
  aws ec2 terminate-instances --instance-ids "$instance_id"

done 
