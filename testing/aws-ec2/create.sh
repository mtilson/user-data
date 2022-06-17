#!/usr/bin/env bash

test -f "$1" || { echo "=== err: file passed as 1-st arg (\"$1\") doesn't exist"; exit -1 ; }
echo "=== log: sourcing file (\"$1\"): START"
source $1
echo "=== log: sourcing file (\"$1\"): DONE"

# ./maps_aws declares the following associative arrays
#   map_os_user
#   map_os_ssm
source ./maps_aws

test -n "$key_name" || { echo "=== err: variable 'key_name' is undeclared" ; exit -2 ; }
test -n "$sg_name" || { echo "=== err: variable 'sg_name' is undeclared" ; exit -3 ; }
test -n "$os_name" || { echo "=== err: variable 'os_name' is undeclared" ; exit -4 ; }
test -n "${map_os_ssm[$os_name]}" || { echo "=== err: variable 'os_name' should be from the list: (${!map_os_ssm[@]})" ; exit -5 ; }

count=${count:-1}
instance_type=${instance_type:-t2.micro}
tag_name_part=${tag_name_part:-general}
tag_type=${tag_type:-mtilson/user-data}

user_data_file=${user_data_file:-../../misc/stub}
test -f "$user_data_file" || { echo "=== err: no file $user_data_file exists" ; exit -6 ; }

ami_id=$(aws ssm get-parameters --names \
  ${map_os_ssm[$os_name]} \
  --query 'Parameters[0].[Value]' \
  --output text)
test -n "$ami_id" || { echo "=== err: AMI ID received for AMI alias ${map_os_ssm[$os_name]} is empty" ; exit -11 ; }

sg_id=$(aws ec2 describe-security-groups \
  --group-names $sg_name \
  --query 'SecurityGroups[*].GroupId' \
  --output text)
test -n "$sg_id" || { echo "=== err: ID received for security group $sg_name is empty" ; exit -21 ; }

vpc_id=$(aws ec2 describe-vpcs \
  --filters Name=isDefault,Values=true \
  --query "Vpcs[*].VpcId" \
  --output text)
test -n "$vpc_id" || { echo "=== err: ID received for default VPC is empty" ; exit -22 ; }

subnet_id=$(aws ec2 describe-subnets \
  --filters Name=vpc-id,Values=$vpc_id \
  --query "Subnets[0].SubnetId" \
  --output text)
test -n "$subnet_id" || { echo "=== err: ID received for 1-st subnet in default VPC is empty" ; exit -23 ; }

tag_specifications="ResourceType=instance,Tags=[{Key=Name,Value=$os_name-$tag_name_part},{Key=Type,Value=$tag_type}]"

cat <<-EOF
	=== Number of instances: $count ===
	    OS type: $os_name
	    AMI SSM parameters path: ${map_os_ssm[$os_name]}
	    AMI ID: $ami_id
	    Instance type: $instance_type
	    Key Pair name: $key_name
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
