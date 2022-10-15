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
tag_name=${tag_name:-general}
tag_type=${tag_type:-mtilson/user-data}

user_data_file=${user_data_file:-../../misc/stub}
test -f "$user_data_file" || { echo "=== err: no file $user_data_file exists" ; exit -6 ; }

ami_id=$(aws ssm get-parameters --names \
  ${map_os_ssm[$os_name]} \
  --query 'Parameters[0].[Value]' \
  --output text)
test -n "$ami_id" || { echo "=== err: AMI ID received for AMI alias ${map_os_ssm[$os_name]} is empty" ; exit -11 ; }

test -z "$tg_name" || {
	tg_arn=$(aws elbv2 describe-target-groups --names $tg_name --query 'TargetGroups[].TargetGroupArn' | jq -c '.[0]' | tr -d '"')
	test -n "$tg_arn" || { echo "=== err: cannot get ARN for the specified target name: $tg_name"; exit -12 ; }
}

filters=""
test -n "$vpc" && { filters="--filters Name=vpc-id,Values=$vpc" ; } || { filters="--filters Name=isDefault,Values=true" ; }
vpc_id=$(aws ec2 describe-vpcs $filters \
  --query "Vpcs[*].VpcId" \
  --output text)
test -n "$vpc_id" || { echo "=== err: ID received for VPC (${vpc}) is empty" ; exit -22 ; }

sg_id=$(aws ec2 describe-security-groups \
  --filters Name=vpc-id,Values=$vpc_id Name=group-name,Values=$sg_name \
  --query 'SecurityGroups[*].GroupId' \
  --output text)
test -n "$sg_id" || { echo "=== err: ID received for security group $sg_name is empty" ; exit -21 ; }

filters=""
test -z "$subnet" || { filters="--filters Name=subnet-id,Values=$subnet" ; }
subnet_id=$(aws ec2 describe-subnets $filters \
  --filters Name=vpc-id,Values=$vpc_id \
  --query "Subnets[0].SubnetId" \
  --output text)
test -n "$subnet_id" || { echo "=== err: ID received subnet (${subnet}) is empty" ; exit -23 ; }

tag_specifications="ResourceType=instance,Tags=[{Key=Name,Value=$tag_name},{Key=Type,Value=$tag_type},{Key=OS,Value=$os_name}]"

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

instance_ids=$(aws ec2 run-instances \
  --image-id "$ami_id" \
  --count "$count" \
  --instance-type "$instance_type" \
  --key-name "$key_name" \
  --user-data "file://${user_data_file}" \
  --security-group-ids "$sg_id" \
  --subnet-id "$subnet_id" \
  --tag-specifications "$tag_specifications" \
  --metadata-options "InstanceMetadataTags=enabled" \
  --query 'Instances[].InstanceId' | jq -c '.[]' | tr -d '"')

test -z "$tg_arn" || {
	echo "=== Target Group ARN: $tg_arn"
	for i in $instance_ids ; do
		echo "    Waiting for running state of Instance with ID: $i"
		#aws ec2 describe-instances --instance-ids $i
		aws ec2 wait instance-running --instance-ids $i
		aws elbv2 register-targets --target-group-arn $tg_arn --targets Id=$i
	done
}
