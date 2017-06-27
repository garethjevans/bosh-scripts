#!/bin/bash -e

echo "Creating Service Account"
export service_account=bosh-user
export project_id=$(gcloud config list 2>/dev/null | grep project | sed -e 's/project = //g')
export service_account_email=${service_account}@${project_id}.iam.gserviceaccount.com

bosh delete-env ../bosh-deployment/bosh.yml \
    --state=director-state.json \
    --vars-store=../creds.yml \
    -o ../bosh-deployment/gcp/cpi.yml \
    -v director_name=gcpbosh \
    -v internal_cidr=10.0.0.0/24 \
    -v internal_gw=10.0.0.1 \
    -v internal_ip=10.0.0.6 \
    --var-file gcp_credentials_json=${service_account_email}.key.json \
    -v project_id=${project_id} \
    -v zone=europe-west1-b \
    -v tags=[internal] \
    -v network=bosh \
    -v subnetwork=bosh-europe-west1
