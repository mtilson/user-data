## Collection of *'user data'* to initialize server OS for various roles

### What is it

*'User data'* are used to initialize OS during instance creation and can be used both for Clouds and for on-premise deployments. For GCP VM the term *'startup scripts'* is used.

Get more details on how to use *'user data'* in Clouds with the following documentation:
* [AWS EC2 - Run commands on your Linux instance at launch](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/user-data.html)
* [Google Compute Engine - Startup scripts overview](https://cloud.google.com/compute/docs/instances/startup-scripts)

### Directory structure

*'User data'* are stored as `user-data` scripts using the `OS/app/component/` directory structure consisted with the following aggregation layers:
* `OS` - operation system layer, e.g.: `ubuntu`
* `app` - application layer, e.g.: `ciscat`
  * for general (*application-agnostic*) components it is possible to use something like `general` as the names for this layer
* `component` - particular application component, e.g.: `mysql` or `tomcat` or `docker`

### How to test *'user data'* using AWS EC2 instances

The repo includes auxiliary scripts to test provided *'user-data'* with help of AWS infrastructure. To use them follow these steps:
* Clone the repo
  * `git clone https://github.com/mtilson/user-data.git`
* Change to `testing/aws-ec2` directory
  * `cd user-data/testing/aws-ec2`
* Create `.env-xxx` file defining the following variables (see the section **Example `.env` files** below)

```
count:          number of EC2 instances to be created; default is '1' if omitted
instance_type:  type of the EC2 instances; default is 't2.micro' if omitted
os_name:        OS name the instance to be based on; required - should be one of the `map_os_ssm` array key defined in file `testing/aws-ec2/maps_aws`, e.g: "ubuntu-18.04" or "ubuntu-20.04")
key_name:       EC2 Key Pair name to be used to access the instances; required
sg_name:        Security Group name for the instances; required
tag_name_part:  part of the instances `Name` tag; default is 'general' if omitted
tag_type:       value of instances `Type` tag; default is 'mtilson/user-data' if omitted
user_data_file: path to the tested `user-data` file to be used for instance initialization; default is '../../misc/stub' if omitted
tg_name:        EC2 Target Group name the instance to be added as a target to; if omitted instance is not added to target group 
```

* Run the command to create corresponding EC2 instances
  * `./create.sh .env-xxx`
* Run the command to list the created EC2 instances
  * `./list.sh .env-xxx`
* Run the command to delete the created EC2 instances
  * `./delete.sh .env-xxx`

#### Example `.env` files

---
##### Docker on Ubuntu 18.04

* Application deployment references
  * [Install Docker Engine on Ubuntu](https://docs.docker.com/engine/install/ubuntu/)
* Example `.env` filename to be created
  * `.env.ubuntu-18.04.general.docker`
```
count=1
instance_type="t2.micro"
os_name="ubuntu-18.04"
key_name="my_key_pair_name"      # replace the value with the name of corresponding key pair
sg_name="my_security_group_name" # replace the value with the name of corresponding security group
tag_name_part="docker"
tag_type="mtilson/docker"
user_data_file="../../ubuntu/18.04/general/docker/user-data"
```
* *'User-data'* file used
  * [`ubuntu/18.04/general/docker/user-data`](ubuntu/18.04/general/docker/user-data)
* Example commands to run
  * `./create.sh .env.ubuntu-18.04.general.docker`
  * `./list.sh .env.ubuntu-18.04.general.docker`
  * `ssh <user>@<host_ip> -t <path to my_key_pair private key>`
    * `<user>` and `<host_ip>` are provided as an output of the `./list.sh ...` command
    * `<path to my_key_pair private key>` corresponding to the EC2 Key Pair
  * `./delete.sh .env.ubuntu-18.04.general.docker`

---
##### Mysql 5 server for CIS-CAT Pro Dashboard on Ubuntu 18.04

* Application deployment references
  * [CIS-CAT Pro Dashboard Deployment Guide for Linux](https://cis-cat-pro-dashboard.readthedocs.io/en/stable/source/Dashboard%20Deployment%20Guide%20for%20Linux/)
* Example `.env` filename to be created
  * `.env.ubuntu-18.04.ciscat.mysql`
```
count=1
instance_type="t2.micro"
os_name="ubuntu-18.04"
key_name="my_key_pair_name"      # replace the value with the name of corresponding key pair
sg_name="my_security_group_name" # replace the value with the name of corresponding security group
tag_name_part="mysql"
tag_type="mtilson/ciscat"
user_data_file="../../ubuntu/18.04/ciscat/mysql/user-data"
```
* *'User-data'* file used
  * [`ubuntu/18.04/ciscat/mysql/user-data`](ubuntu/18.04/ciscat/mysql/user-data)
* Example commands to run
  * `./create.sh .env.ubuntu-18.04.ciscat.mysql`
  * `./list.sh .env.ubuntu-18.04.ciscat.mysql`
  * `ssh <user>@<host_ip> -t <path to my_key_pair private key>`
    * `<user>` and `<host_ip>` are provided as an output of the `./list.sh ...` command
    * `<path to my_key_pair private key>` corresponding to the EC2 Key Pair
  * `./delete.sh .env.ubuntu-18.04.ciscat.mysql`

---
##### Tomcat 9 server for CIS-CAT Pro Dashboard on Ubuntu 18.04

* Application deployment references
  * [CIS-CAT Pro Dashboard Deployment Guide for Linux](https://cis-cat-pro-dashboard.readthedocs.io/en/stable/source/Dashboard%20Deployment%20Guide%20for%20Linux/)
  * [How To Install Apache Tomcat 9 on Ubuntu 18.04](https://www.digitalocean.com/community/tutorials/install-tomcat-9-ubuntu-1804)
* Example `.env` filename to be created
  * `.env.ubuntu-18.04.ciscat.tomcat`
```
count=1
instance_type="t2.micro"
os_name="ubuntu-18.04"
key_name="my_key_pair_name"      # replace the value with the name of corresponding key pair
sg_name="my_security_group_name" # replace the value with the name of corresponding security group
tag_name_part="tomcat"
tag_type="mtilson/ciscat"
user_data_file="../../ubuntu/18.04/ciscat/tomcat/user-data"
tg_name="ciscat"
```
* *'User-data'* file used
  * [`ubuntu/18.04/ciscat/tomcat/user-data`](ubuntu/18.04/ciscat/tomcat/user-data)
* Example commands to run
  * `./create.sh .env.ubuntu-18.04.ciscat.tomcat`
  * `./list.sh .env.ubuntu-18.04.ciscat.tomcat`
  * `ssh <user>@<host_ip> -t <path to my_key_pair private key>`
    * `<user>` and `<host_ip>` are provided as an output of the `./list.sh ...` command
    * `<path to my_key_pair private key>` corresponding to the EC2 Key Pair
  * `./delete.sh .env.ubuntu-18.04.ciscat.tomcat`
