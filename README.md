# Table of contents

- [DATA MESH](#focusing-manager)
  - [Table of contents](#table-of-contents)
  - [Requirements](#requirements)
  - [Deployment](#step-by-step-deployment)
      - [FHIR](#fhir-server)
      - [OMOP](#omop)
      - [OHDSI-API](#ohdsi-api)
  - [Test deployment](#test-deployment)
  - [Clean Up](#clean-up)
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

Install Istio and enable injection in the datamesh ns

```shell
istioctl install --set profile=demo -y 

```
Set up a namespace to ensure the encapsulation of the services with mTLS. It also set the Istio sidecar injection automatically
```shell
kubectl apply -f kubernetes/base/001_datamesh-ns.yaml
```
Now we enforce the mTLS policy along the namespace we just created and we create the Istio Gateway resource pointing to localhost for local development 

```shell 
kubectl apply -f kubernetes/base/002_mtls-policy.yaml

kubectl apply -f kubernetes/base/003_gateway.yaml
```
### FHIR Server
We can apply all the files in the [hir-services](./kubernetes/fhir-services) folder at the same time by doing:

```shell
kubectl apply -f kubernetes/fhir-services/
```
### OMOP 

Setting up OMOP is done by creating first a postgres DB and the populating it with the vocabularies for the project. More info in [this repo](https://github.com/IDEA4RC/OMOP-Automatic-Deploy).

```shell
kubectl apply -f kubernetes/omop-services/
```
Wait for the Job that populates the OMOP database before continuing to the next step.
Once the pod `populate-db` is finished it will show:
```shell
NAME                             READY   STATUS    RESTARTS       AGE
omop-cdm-db-xxx                  2/2     Running    0             x
populate-db-xxx                  1/2     NotReady   1             x
```

And by looking to the logs it will show `All done, shutting down. Feel free to remove container.`

### OHDSI API

This API will anable the communication of the capsule with the Vantage 6 nodes and server.

In order to install it first a number of services must be installed to work together with the API. These are dependant of a config map that contains the connection details. (Note that the passwords must be changed in a production enviroment)

```shell
kubectl apply -f kubernetes/ohdsi-api/001_connection-details.yaml

kubectl apply -f kubernetes/ohdsi-api/sub-services/

kubectl apply -f kubernetes/ohdsi-api/002_ohdsi-api-deployment.yaml
kubectl apply -f kubernetes/ohdsi-api/003_ohdsi-api-svc.yaml
kubectl apply -f kubernetes/ohdsi-api/004_ohdsi-api-vs.yaml
```

## Test deployment

In order to test the endpoints available first we should check that the OHDSI API services are up and running:
This deploymnet works in the local machine network `127.0.0.1`. We assume the same configuration for the testing.

The `/ohdsi-api` endpoint can be tested by:
```shell
curl http://127.0.0.1/ohdsi-api/health
```
With the expected output:
```json
{
    "API": "ok",
    "database": "ok",
    "celery": "ok",
    "celery_backend": "ok"
}
```
The `/fhir` endpoint can be tested by doing a simple request to the Patient resource:

```shell
curl http://127.0.0.1/fhir/Patient
```
With the expected output being somenthing similar to:
```json
{
    "resourceType": "Bundle",
    "id": "f61fed84-f65d-4ff2-8316-27f9185e3671",
    "meta": {
        "lastUpdated": "2024-02-05T10:52:59.517+00:00"
    },
    "type": "searchset",
    "total": 0,
    "link": [
        {
            "relation": "self",
            "url": "http://127.0.0.1/fhir/Patient"
        }
    ]
}
```
## Clean up

Follow the steps to clean up

```bash
kubectl delete -f ./kubernetes/fhir-services

kubectl delete -f ./kubernetes/omop-services

kubectl delete -f ./kubernetes/ohdsi-api/sub-services

kubectl delete -f ./kubernetes/omop-services

kubectl delete -f ./kubernetes/ohdsi-api

kubectl delete -f ./kubernetes/base

istioctl uninstall --purge -y

kubectl delete namespace istio-system
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
