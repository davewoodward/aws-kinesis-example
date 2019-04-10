#!/bin/bash

if [ -f ./env.sh ]; then
  . ./env.sh
fi

terraform init
terraform apply
