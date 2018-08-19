#!/bin/bash


# no service 
#kubectl run my-nginx --image=nginx --replicas=4 --port=80 


# service nodePort
kubectl run my-nginx --image=nginx --replicas=4 --port=80 
kubectl expose deployment my-nginx --type=NodePort --name=example-service-nodeport


# service ClusterIp
#kubectl run my-nginx --image=nginx --replicas=4 --port=80 
#kubectl expose deployment nginx --name=example-service


# have service
#kubectl run my-nginx --image=nginx --replicas=4 --port=80 --expose 
