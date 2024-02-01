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
### FHIR Server
- We can apply all the files in the [hir-services](./kubernetes/fhir-services) folder:

```shell
kubectl apply -f kubernetes/fhir-services/
```
### OMOP 

Setting up OMOP is done by creating first a postgres DB and the populating it with the vocabularies for the project. More info in [this repo](https://github.com/IDEA4RC/OMOP-Automatic-Deploy).

```shell
kubectl apply -f kubernetes/omop-services/
```

### OHDSI API

This API will anable the communication of the capsule with the Vantage 6 nodes and server.

In order to install it first a number of services must be installed to work together with the API. These are dependant of a config map that contains the connection details. (Note that the passwords must be changed in a production enviroment)

```shell
kubectl apply -f kubernetes/ohdsi-api/001_connection-details.yaml

kubectl apply -f kubernetes/ohdsi-api/sub-services/

kubectl apply -f kubernetes/omop-services/002_omop-db-cdm-deployment.yaml
kubectl apply -f kubernetes/omop-services/003_omop-db-svc-datamesh.yaml
kubectl apply -f kubernetes/omop-services/004_omop-vocab-job.yaml
```

## Development

To contribute to the repo create a fork and make a pull request explaining the behaviour of the changes.

## Getting help

Feel free to create an issue if some bugs are detected or you need help.


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
