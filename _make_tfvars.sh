#!/bin/bash

if [ $# != 1 ]; then
	echo "usage: $0 project_name (must be [a-z](alphabet, lower case) 4-8 chars)"
        exit 1
fi

# Project Name Char length
MIN_LEN=4; MAX_LEN=8

if [[ ! "$1" =~ ^[a-z]{$MIN_LEN,$MAX_LEN}$ ]]; then
	echo "project_name: must be alphabet(a-z) lower case, 4-8 chars"
	exit 1
fi

if [ ! -f terraform.tfvars._TEMPLATE ]; then
        echo "terraform.tfvars._TEMPLATE is not exists."
        exit 1
fi

if [ -f $1/terraform.tfvars.$1 ]; then
        echo "$1/terraform.tfvars.$1 is exists."
        echo "please delete $1/terraform.tfvars.$1 first."
        exit 1
fi

mkdir -p $1
cd $1
ln -s ../*.tf ./
mkdir ./ssh
(cd ssh
ssh-keygen -t rsa -b 4096 -C "" -f id_rsa -N "")
cp -r ../certs ./
cd ..

cat terraform.tfvars._TEMPLATE | \
        sed "s/%%proj_name%%/$1/g" > $1/terraform.tfvars.$1

echo "cd $1"
echo "Edit terraform.tfvars.$1"
echo "run: terraform init"
echo "run: terraform plan -var-file terraform.tfvars.$1"
echo "run: terraform apply -var-file terraform.tfvars.$1"


