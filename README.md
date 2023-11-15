# Table of contents

- [DATA MESH](#focusing-manager)
  - [Table of contents](#table-of-contents)
  - [Requirements](#requirements)
  - [Deployment](#step-by-step-deployment)
  - [Development](#development)
  - [Getting help](#getting-help)
  - [License](#license)
  - [Authors and history](#authors-and-history) 
  
# DATA MESH

This mesh will be defined to be the infrastructure to hold the data, giving it an extra layer of security by creating a zero trust network to hold the databases and creating spefic role based authentication to the ETL to populate the databases.

The following figure explains the database architecture contained in this mesh.

![Diagram](./doc/imgs/CapsuleSchema.png)


## Requirements

This deployment uses a kuberntes cluster and the recomended amount of resources is 4 CPUs and 16GB of RAM for the Istio deployment to run smoothly.

## Step-by-step Deployment


After downloading Istio procced with:

- Install Istio and enable injection in the datamesh ns

```shell
istioctl install --set profile=demo -y 

```
- Set up a namespace to ensure the encapsulation of the services with mTLS. It also set the Istio sidecar injection automatically
```shell
kubectl apply -f kubernetes/base/001_datamesh-ns.yaml

kubectl label namespace datamesh istio-injection=enabled --overwrite
```
- Now we enforce the mTLS policy along the namespace we just created and we create the Istio Gateway resource pointing to localhost for local development 

```shell 
kubectl apply -f kubernetes/base/002_mtls-policy.yaml

kubectl apply -f kubernetes/base/003_gateway.yaml
```
- Then we apply the rest of the yamls from the previous steps but with the namespace "datamesh"

```shell
kubectl apply -f kubernetes/fhir-services/004_postgress-secret-datamesh.yaml

kubectl apply -f kubernetes/fhir-services/005_postgres-db-datamesh.yaml

kubectl apply -f kubernetes/fhir-services/006_postgres-svc-datamesh.yaml

kubectl apply -f kubernetes/fhir-services/007_fhir-deployment-datamesh.yaml

kubectl apply -f kubernetes/fhir-services/008_fhir-server-svc.yaml

kubectl apply -f kubernetes/fhir-services/009_fhir-server-vs.yaml
```

- Setting up the example authentication and authorization policies

```shell
kubectl apply -f kubernetes/least-privilege-access/010_request-auth.yaml

kubectl apply -f kubernetes/least-privilege-access/011_auth-policy-patient.yaml

kubectl apply -f kubernetes/least-privilege-access/012_auth-policy-medic.yaml
```

## Development

To contribute to the repo create a fork and make a pull request explaining the behaviour of the changes.

## Getting help



License
------

```
Copyright 2023 Universidad Politécnica de Madrid

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```

Authors and history
---------------------------
- Alejo Esteban ([@aeolmo]())
- Alejandro Alonso ([@aalonso]())
