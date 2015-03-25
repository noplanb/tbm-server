#!/bin/sh
environment=$1
[ -z ${environment} ] && environment=${RACK_ENV}
[ -z ${environment} ] && environment="staging"
repo_url="https://github.com/noplanb/tbm-server"
revision=$(git rev-parse HEAD)
channel="#dev"
username="Elastic Beanstalk"
commit_url="${repo_url}/commit/${revision}"
revision_short=${revision:0:8}
case ${environment} in
  production) eb_environment="zazo-prod2-0-1"
    ;;
  *) eb_environment="zazo-${environment}"
    ;;
esac
text="Deploying <${commit_url}|${revision_short}> to Zazo *${environment}* -> *${eb_environment}* by ${USER}"
echo "Deploying ${revision_short} to Zazo ${environment} -> ${eb_environment} by ${USER}"
curl -X POST --data-urlencode "payload={\"text\": \"${text}\", \"channel\": \"${channel}\", \"username\": \"${username}\"}" https://hooks.slack.com/services/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
eb deploy ${eb_environment}
bundle exec rake airbrake:deploy TO=${environment} REVISION=${revision} REPO=${repo_url}
