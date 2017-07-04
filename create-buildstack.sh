#!/bin/bash -e

bosh alias-env gcpbosh -e 10.0.0.6 --ca-cert <(bosh int ../creds.yml --path /director_ssl/ca)

export BOSH_CLIENT=admin
export BOSH_CLIENT_SECRET=`bosh int ../creds.yml --path /admin_password`

bosh -e 10.0.0.6 update-cloud-config cloud-config.yml

bosh -e 10.0.0.6 upload-release https://storage.googleapis.com/buildstack-blobs/buildstack-boshrelease.tgz

bosh int --vars-store ../buildstack-deployment-vars.yml \
    --var-errs \
    buildstack-deployment.yml

bosh -e 10.0.0.6 -d buildstack deploy \
    --vars-store ../buildstack-deployment-vars.yml \
    buildstack-deployment.yml
