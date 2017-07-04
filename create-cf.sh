#!/bin/bash -e

bosh alias-env gcpbosh -e 10.0.0.6 --ca-cert <(bosh int ../creds.yml --path /director_ssl/ca)

export BOSH_CLIENT=admin
export BOSH_CLIENT_SECRET=`bosh int ../creds.yml --path /admin_password`
MODEL=base

bosh -e 10.0.0.6 update-cloud-config cloud-config.yml

bosh -e 10.0.0.6 upload-stemcell https://bosh.io/d/stemcells/bosh-google-kvm-ubuntu-trusty-go_agent?v=3421.6

bosh int --vars-store ../cf-deployment-vars.yml \
    -o ../cf-deployment/operations/gcp.yml \
    -o downsize.yml \
    -o downsize-diego-cell-disk-usage.yml \
    -o log-trace-tokens.yml \
    -o ${MODEL}-model.yml \
    --var-errs \
    ../cf-deployment/cf-deployment.yml

bosh -e 10.0.0.6 -d cf deploy \
    --vars-store ../cf-deployment-vars.yml \
    -o ../cf-deployment/operations/gcp.yml \
    -o downsize.yml \
    -o downsize-diego-cell-disk-usage.yml \
    -o log-trace-tokens.yml \
    -o ${MODEL}-model.yml \
    ../cf-deployment/cf-deployment.yml
