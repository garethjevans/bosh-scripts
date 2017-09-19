#!/bin/bash -e

bosh alias-env gcpbosh -e 10.0.0.6 --ca-cert <(bosh int ../bosh-vars.yml --path /director_ssl/ca)

export BOSH_CLIENT=admin
export BOSH_CLIENT_SECRET=`bosh int ../bosh-vars.yml --path /admin_password`

MODEL=base
CF_DEPLOYMENT_VERSION=v0.27.0

cd ../cf-deployment
git checkout master
git pull
git checkout $CF_DEPLOYMENT_VERSION
cd -

bosh -e 10.0.0.6 update-cloud-config cloud-config.yml --non-interactive
bosh -e 10.0.0.6 upload-stemcell https://bosh.io/d/stemcells/bosh-google-kvm-ubuntu-trusty-go_agent?v=3445.7 --non-interactive

bosh int --vars-store ../cf-deployment-vars.yml \
    -o ../cf-deployment/operations/gcp.yml \
    -o rolling-updates-to-diego-cells.yml \
    -o downsize.yml \
    -o log-trace-tokens.yml \
    -o ${MODEL}-model.yml \
    --var-errs \
    --var-errs-unused \
    ../cf-deployment/cf-deployment.yml


bosh -e 10.0.0.6 -d cf deploy \
    --vars-store ../cf-deployment-vars.yml \
    -o ../cf-deployment/operations/gcp.yml \
    -o rolling-updates-to-diego-cells.yml \
    -o downsize.yml \
    -o log-trace-tokens.yml \
    -o ${MODEL}-model.yml \
    ../cf-deployment/cf-deployment.yml

