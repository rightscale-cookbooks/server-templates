#! /bin/bash -ex

# ---
# RightScript Name: Packer Install tools for ARM
# Description: |
#   Install the tools for Packer and ARM
# Inputs:
#   CLOUD:
#     Category: Cloud
#     Description: |
#       Select the cloud you are launching in
#     Input Type: single
#     Required: true
#     Advanced: false
#     Possible Values:
#     - text:ec2
#     - text:google
#     - text:azurerm
# Attachments: []
# ...

if [ "$CLOUD" == "azurerm" ];then
  PACKER_DIR=/tmp/packer
  PACKER_VERSION=0.9.0
  mkdir -p ${PACKER_DIR}
  export DEBIAN_FRONTEND=noninteractive
  sudo apt-get -y update
  cd ${PACKER_DIR}
  packer_zip="packer_${PACKER_VERSION}_linux_amd64.zip"
  mv /tmp/packer/packer /tmp/packer/packer.old
  [ -f ./packer ] && rm packer
  wget https://privatecloudtools.s3.amazonaws.com/packer
  chmod +x /tmp/packer/packer
fi