#! /bin/bash

# This script is used to setup the environment for the project
echo "1- Installing the Custom Istio Operator"
istioctl install -f ./kubernetes/temp-deployment/001_IstioOperator.yaml -y



echo "2- Installing Gateway"
kubectl apply -f ./kubernetes/temp-deployment/002_gateway.yaml

echo "3- Enabling the Istio Sidecar Injection"
kubectl label namespace datamesh istio-injection=enabled --overwrite

echo "4- Installing OMOP services. Populating the database may take a while. Please be patient."
kubectl apply -f ./kubernetes/omo-services
kubectl apply -f ./kubernetes/temp-deployment/003_omop-vs.yaml

sleep 100

echo "5- Installing the DataMesh services"
