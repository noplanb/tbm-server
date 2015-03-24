#!/bin/sh
environment=$1
[ -z ${environment} ] && environment=${RACK_ENV}
[ -z ${environment} ] && environment="production"
repo_url="https://github.com/noplanb/tbm-server"
revision=$(git rev-parse HEAD)
channel="#dev"
username="Elastic Beanstalk"
commit_url="${repo_url}/commit/${revision}"
text="Deploying <${commit_url}|${revision:0:8}> to Zazo *${environment}* environment"
echo "${text} -> ${channel} @ ${username}"
curl -X POST --data-urlencode "payload={\"text\": \"${text}\", \"channel\": \"${channel}\", \"username\": \"${username}\"}" https://hooks.slack.com/services/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
bundle exec rake airbrake:deploy TO=${environment} REVISION=${revision} REPO=${repo_url}
