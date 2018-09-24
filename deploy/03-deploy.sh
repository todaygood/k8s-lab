#!/usr/bin/env  bash 

KUBESPAY=../kubespray
ansible-playbook -u centos -b -i $KUBESPAY/inventory/inventory.cfg $KUBESPAY/cluster.yml

ansible-playbook -i $KUBESPAY/inventory/inventory.cfg $KUBESPAY/scripts/copy-kubeconfig.yaml
