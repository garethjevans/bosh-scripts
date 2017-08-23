#!/bin/bash -e

#bosh alias-env gcpbosh -e 10.0.0.6 --ca-cert <(bosh int ../creds.yml --path /director_ssl/ca)

#export BOSH_CLIENT=admin
#export BOSH_CLIENT_SECRET=`bosh int ../creds.yml --path /admin_password`
#export BOSH_ENVIRONMENT=gcpbosh

bosh update-cloud-config cloud-config.yml --non-interactive

cd ../buildstack-boshrelease
git pull
bosh create-release --force
bosh upload-release

echo "========================================================="
bosh -d buildstack int \
    --vars-store ../buildstack-deployment-vars.yml \
    $* \
    buildstack.yml
echo "========================================================="

bosh -d buildstack deploy \
    --vars-store ../buildstack-deployment-vars.yml \
    $* \
    buildstack.yml 
