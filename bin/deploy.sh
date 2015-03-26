#!/bin/sh

# Functions

notify() {
  local text=$1
  local color=$2
  echo "${text}"
  curl -X POST --data-urlencode "payload={\"channel\": \"${channel}\", \"username\": \"${username}\", \"attachments\": [{\"color\": \"${color}\", \"text\": \"${text}\", \"mrkdwn_in\": [\"text\"] }]}" https://hooks.slack.com/services/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
}

# Variables

application="zazo"
environment=$1
[ -z ${environment} ] && environment=${RACK_ENV}
[ -z ${environment} ] && environment="staging"
case ${environment} in
  production) eb_environment="zazo-prod2-0-1"
    ;;
  *) eb_environment="zazo-${environment}"
    ;;
esac

# Git

repo_url="https://github.com/noplanb/tbm-server"
revision=$(git rev-parse HEAD)
branch=$(git rev-parse --abbrev-ref HEAD)
channel="#dev"
username="Elastic Beanstalk"
commit_url="${repo_url}/commit/${revision}"
revision_short=${revision:0:8}

# Slack

common_text="branch \`${branch}\` <${commit_url}|${revision_short}> of ${application} to *${environment}* [${eb_environment}]"
started_text="${USER} has started deploying ${common_text}"
failed_text="${USER} failed to deploy ${common_text}"
finished_text="${USER} has finished deploying ${common_text}"

# Deploy command

deploy_cmd="eb deploy ${eb_environment}"

# Commands

notify "${started_text}"
if $(${deploy_cmd}); then
  bundle exec rake airbrake:deploy TO=${environment} REVISION=${revision} REPO=${repo_url}
  notify "${finished_text}" good
else
  notify "${failed_text}" danger
fi
