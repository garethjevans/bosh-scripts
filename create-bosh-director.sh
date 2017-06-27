#!/bin/bash -e

export service_account=bosh-user
export base_ip=10.0.0.0
export project_id=$(gcloud config list 2>/dev/null | grep project | sed -e 's/project = //g')
export service_account_email=${service_account}@${project_id}.iam.gserviceaccount.com

if [[ ! $(gcloud iam service-accounts list | grep ${service_account}) ]]; then
	gcloud iam service-accounts create ${service_account}
fi

if [[ ! -f ~/.ssh/bosh ]]; then
	gcloud projects add-iam-policy-binding ${project_id} \
    	  	--member serviceAccount:${service_account_email} \
        	--role roles/compute.instanceAdmin
	gcloud projects add-iam-policy-binding ${project_id} \
      		--member serviceAccount:${service_account_email} \
        	--role roles/compute.storageAdmin
	gcloud projects add-iam-policy-binding ${project_id} \
      		--member serviceAccount:${service_account_email} \
        	--role roles/storage.admin
	gcloud projects add-iam-policy-binding ${project_id} \
      		--member serviceAccount:${service_account_email} \
        	--role  roles/compute.networkAdmin
	gcloud projects add-iam-policy-binding ${project_id} \
      		--member serviceAccount:${service_account_email} \
        	--role roles/iam.serviceAccountActor

    ssh-keygen -t rsa -f ~/.ssh/bosh -C bosh
    gcloud compute project-info add-metadata --metadata-from-file \
            sshKeys=<( gcloud compute project-info describe --format=json | jq -r '.commonInstanceMetadata.items[] | select(.key ==  "sshKeys") | .value' & echo "bosh:$(cat ~/.ssh/bosh.pub)" )
fi

if [ ! -f ${service_account_email}.key.json ]; then
    gcloud iam service-accounts keys create ${service_account_email}.key.json \
            --iam-account ${service_account_email}
fi

echo "==================================================================="
bosh int ../bosh-deployment/bosh.yml \
    --vars-store=../creds.yml \
    -o ../bosh-deployment/gcp/cpi.yml \
    -v director_name=gcpbosh \
    -v internal_cidr=10.0.0.0/24 \
    -v internal_gw=10.0.0.1 \
    -v internal_ip=10.0.0.6 \
    --var-file gcp_credentials_json=${service_account_email}.key.json \
    -v project_id=${project_id} \
    -v zone=europe-west1-b \
    -v tags=[internal,no-ip] \
    -v network=bosh \
    -v subnetwork=bosh-europe-west1
echo "==================================================================="

bosh create-env ../bosh-deployment/bosh.yml \
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
    -v tags=[internal,no-ip] \
    -v network=bosh \
    -v subnetwork=bosh-europe-west1
