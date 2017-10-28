#!/usr/bin/env bash

yum install -y python2-cryptography  openssl-libs  python-crypto  openssl-devel libffi libffi-devel python-devel 
pip2 install kubespray



# ansible 2.3 
pip2 install ansible


# Jinja2 2.9
pip2 install -U jinja2
