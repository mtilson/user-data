#!/usr/bin/env bash

test -f "$1" || { echo "error: file passed as 1-st arg (\"$1\") doesn't exist"; exit -1 ; }
source $1

test ${#map_os_ssm[@]} -ne 0 || { echo "nothing to do: array 'map_os_ssm' is empty or undeclared" ; exit -2 ; }
test -n "$key_name" || { echo "error: variable 'key_name' is undeclared" ; exit -2 ; }
test -n "$sg_name" || { echo "error: variable 'sg_name' is undeclared" ; exit -2 ; }

count=${count:-1}
instance_type=${instance_type:-t2.micro}
tag_name_part=${tag_name_part:-general}
tag_type=${tag_type:-mtilson/user-data}

user_data_file=${user_data_file:-../stub.sh}
test -f "$user_data_file" || { echo "error: no file $user_data_file exists; exiting" ; exit -1 ; }

sg_id=$(aws ec2 describe-security-groups \
  --group-names $sg_name \
  --query 'SecurityGroups[*].GroupId' \
  --output text)
test -n "$sg_id" || { echo "error: ID received for security group $sg_name is empty; exiting" ; exit -1 ; }

vpc_id=$(aws ec2 describe-vpcs \
  --filters Name=isDefault,Values=true \
  --query "Vpcs[*].VpcId" \
  --output text)
test -n "$vpc_id" || { echo "error: ID received for default VPC is empty; exiting" ; exit -1 ; }

subnet_id=$(aws ec2 describe-subnets \
  --filters Name=vpc-id,Values=$vpc_id \
  --query "Subnets[0].SubnetId" \
  --output text)
test -n "$subnet_id" || { echo "error: ID received for 1-st subnet in default VPC is empty; exiting" ; exit -1 ; }

let i=0
for os in "${!map_os_ssm[@]}"; do
  let i++
  tag_specifications="ResourceType=instance,Tags=[{Key=Name,Value=$os-$tag_name_part},{Key=Type,Value=$tag_type}]"

  ami_id=$(aws ssm get-parameters --names \
    ${map_os_ssm[$os]} \
    --query 'Parameters[0].[Value]' \
    --output text)
  test -n "$ami_id" || { echo "error: AMI ID received for AMI alias ${map_os_ssm[$os]} is empty; continue to next loop iteration" ; continue ; }

  cat <<-EOF
	== Instance $i ==
	   OS type: $os
	   AMI name alias: ${map_os_ssm[$os]}
	   AMI ID: $ami_id
	   Count: $count
	   Instance type: $instance_type
	   Key name: $key_name
	   User Data file name: $user_data_file
	   SG name: $sg_name
	   SG ID: $sg_id
	   VPC ID: $vpc_id
	   Subnet ID: $subnet_id
	   Tag specifications: $tag_specifications
	EOF

  aws ec2 run-instances \
  --image-id "$ami_id" \
  --count "$count" \
  --instance-type "$instance_type" \
  --key-name "$key_name" \
  --user-data "file://${user_data_file}" \
  --security-group-ids "$sg_id" \
  --subnet-id "$subnet_id" \
  --tag-specifications "$tag_specifications"

done
