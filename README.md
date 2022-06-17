## Collection of *'user data'* to initialize server OS for various roles

### What is it

*'User data'* are used to initialize OS during instance creation and can be used both for Clouds and for on-premis deployments

### Directory structure

*'User data'* are stored as `user-data` scripts using the `OS/app/component/` directory structure consisted with the following aggregation layers

* `OS` - operation system layer, e.g.: `ubuntu`
* `app` - application layer, e.g.: `ciscat`
  * for general (*application-agnostic*) components it is possible to use something like `general` as the names for this layer
* `component` - particular application component, e.g.: `mysql` or `tomcat` or `docker`

### How to test *'user data'* using AWS EC2 instances

There are auxiliary scripts to test provided *user-data* with help of AWS infrastructure. To use then follow these steps

* Clone the repo
  * `git clone https://github.com/mtilson/user-data.git`
* Change to `testing/aws-ec2` directory
  * `cd user-data/testing/aws-ec2`
* Create `.env-xxx` file defining the following variables (see the section **Example `.env` files** below)

```
count:          number of EC2 instances to be created
instance_type:  type of the EC2 instances
os_name:        OS name the instance to be based on (it should be one of the `map_os_ssm` array key defined in file `testing/aws-ec2/maps_aws`, e.g: "ubuntu-18.04" or "ubuntu-20.04")
key_name:       EC2 Key Pair name to be used to access the instances
sg_name:        Security Group for the instances
tag_name_part:  part of the instances `Name` tag
tag_type:       value of instances `Type` tag
user_data_file: path to the tested `user-data` file to be used for instance initialization
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

* User-data file
  * `ubuntu/18.04/general/docker/user-data`
* Example `.env` filename to be created
  * `.env.ubuntu-18.04.general.docker`
* Example command to run
  * `./create.sh .env.ubuntu-18.04.general.docker`
* References
  * [Install Docker Engine on Ubuntu](https://docs.docker.com/engine/install/ubuntu/)

```
count=1
instance_type="t2.micro"
os_name="ubuntu-18.04"
key_name="my_key_pair_name"
sg_name="my_security_group_name"
tag_name_part="docker-general"
tag_type="mtilson/docker"
user_data_file="../../ubuntu/18.04/general/docker/user-data"
```

---
##### Mysql server for CIS-CAT Pro Dashboard on Ubuntu 18.04

* User-data file
  * `ubuntu/18.04/ciscat/mysql/user-data`
* Example `.env` filename to be created
  * `.env.ubuntu-18.04.ciscat.mysql`
* Example command to run
  * `./create.sh .env.ubuntu-18.04.ciscat.mysql`
* References
  * [CIS-CAT Pro Dashboard Deployment Guide for Linux](https://cis-cat-pro-dashboard.readthedocs.io/en/stable/source/Dashboard%20Deployment%20Guide%20for%20Linux/)

```
count=1
instance_type="t2.micro"
os_name="ubuntu-18.04"
key_name="my_key_pair_name"
sg_name="my_security_group_name"
tag_name_part="mysql-ciscat"
tag_type="mtilson/ciscat"
user_data_file="../../ubuntu/18.04/ciscat/mysql/user-data"
```
