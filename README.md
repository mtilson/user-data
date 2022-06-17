# user-data

## How to use

### AWS EC2

* Clone the repo
  * `git clone https://github.com/mtilson/user-data.git`
* Change to `aws-ec2` directory of the cloned repo
  * `cd user-data/aws-ec2`
* Create `.env-xxx` file with the following content defining variables, see the examples of `.env` files below

```
count:          number of EC2 instances to be created
instance_type:  EC2 instance type
key_name:       EC2 Key Pair name for the instances
sg_name:        Security Group for the instances
tag_name_part:  part of the `Name` tag
tag_type:       value of `Type` tag
user_data_file: path to user-data file to init the instances - use `ubuntu-18.04/*/user-data` file as examples
map_os_ssm:     bash 'NAMEs associative arrays' to store a map of 'OS-type' to 'SSM parameter name' for OS-type AMI ID correspondence
```

* Run the following command to create corresponding EC2 instances
  * `./create.sh .env-xxx`
* Run the following command to list the created EC2 instances
  * `./list.sh .env-xxx`
* Run the following command to delete the created EC2 instances
  * `./delete.sh .env-xxx`

## Examples `.env` files

---
### Docker on Ubuntu 18.04

* User-data file
  * `ubuntu-18.04/docker/user-data`
* Example `.env` filename
  * `.env.ubuntu-18.04.docker`
* Example command
  * `./create.sh .env.ubuntu-18.04.docker`
* References
  * [Install Docker Engine on Ubuntu](https://docs.docker.com/engine/install/ubuntu/)

```
count=1
instance_type="t2.micro"
key_name="myKeyPairName"
sg_name="mySecurityGroupName"
tag_name_part="docker:
tag_type="mtilson/user-data/docker"
user_data_file="../ubuntu-18.04/docker/user-data"

declare -A map_os_ssm=( \
  ["ubuntu-18.04"]="/aws/service/canonical/ubuntu/server/bionic/stable/current/amd64/hvm/ebs-gp2/ami-id" \
)
```

---
### Mysql server for CIS-CAT Pro Dashboard on Ubuntu 18.04

* User-data file
  * `ubuntu-18.04/ciscat/mysql/user-data`
* Example filename
  * `.env.ubuntu-18.04.ciscat.mysql`
* Example command
  * `./create.sh .env.ubuntu-18.04.ciscat.mysql`
* References
  * [CIS-CAT Pro Dashboard Deployment Guide for Linux](https://cis-cat-pro-dashboard.readthedocs.io/en/stable/source/Dashboard%20Deployment%20Guide%20for%20Linux/)

```
count=1
instance_type="t2.micro"
key_name="myKeyPairName"
sg_name="mySecurityGroupName"
tag_name_part="mysql-ciscat"
tag_type="mtilson/user-data/ciscat"
user_data_file="../ubuntu-18.04/ciscat/mysql/user-data"

declare -A map_os_ssm=( \
  ["ubuntu-18.04"]="/aws/service/canonical/ubuntu/server/bionic/stable/current/amd64/hvm/ebs-gp2/ami-id" \
)
```
