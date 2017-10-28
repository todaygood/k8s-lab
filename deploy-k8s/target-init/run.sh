#!/usr/bin/env bash

rm -f *retry

inventory=../kubespray/inventory/inventory.cfg 

ansible-playbook site.yml -i $inventory

