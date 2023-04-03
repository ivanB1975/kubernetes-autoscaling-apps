#!/bin/bash

## Creation of the docker image

cd docker

docker build -t kube-challenge/flask-app .

cd ..


# Sending the image to the minikube cluster

minikube image load kube-challenge/flask-app

# Creating the deployments app1 and app2

kubectl apply -f deployments.yml

# Creating the services

kubectl apply -f services.yml

# Getting the ip of the minikube to use it in the hosts file

ip=$(minikube ip)

echo "$ip"

# Adding the following line to /etc/hosts
# 192.168.49.2 simple-web-app.com

sudo -- sh -c "echo $ip  simple-web-app.com >> /etc/hosts"


# Creating the ingress

kubectl apply -f ingresses/ingress_apps.yml

# Setting the cluster role

kubectl apply -f cluster_role_scaler.yml

# Binding the role to the default serviceaccount


kubectl create clusterrolebinding deployments-scaler \
  --clusterrole=deployments-scaler  \
  --serviceaccount=default:default

# Creating 4 cronjobs

kubectl apply -f cronjobs/app1_up.yml,cronjobs/app1_down.yml,cronjobs/app2_up.yml,cronjobs/app2_down.yml
