#!/bin/bash -e

bosh alias-env gcpbosh -e 10.0.0.6 --ca-cert <(bosh int ../creds.yml --path /director_ssl/ca)

export BOSH_CLIENT=admin
export BOSH_CLIENT_SECRET=`bosh int ../creds.yml --path /admin_password`
export BOSH_ENVIRONMENT=10.0.0.6

bosh -d cf run-errand smoke-tests
