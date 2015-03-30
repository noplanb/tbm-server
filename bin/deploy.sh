#!/bin/bash

# Functions

notify_slack() {
  local username="Elastic Beanstalk"
  local channel="#dev"
  local text=$1
  local color=$2

  echo -n ${text} "-> "
  curl -X POST --data-urlencode "payload={\"channel\": \"${channel}\", \"username\": \"${username}\", \"attachments\": [{\"color\": \"${color}\", \"text\": \"${text}\", \"mrkdwn_in\": [\"text\"] }]}" https://hooks.slack.com/services/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
  echo
}

notify_rollbar() {
  local rollbar_username=${local_user}
  local comment=$2
  curl https://api.rollbar.com/api/1/deploy/ \
    -F access_token=${rollbar_access_token} \
    -F environment=${environment} \
    -F revision=${revision} \
    -F local_username=${local_user} \
    -F rollbar_username=${rollbar_username} \
    -F comment=${comment}
  echo
}

# Variables

application="zazo"
environment=$1
[ -z ${environment} ] && environment=${RACK_ENV}
[ -z ${environment} ] && environment="staging"
case ${environment} in
  production) eb_environment="${application}-prod2-0-1"
    ;;
  *) eb_environment="${application}-${environment}"
    ;;
esac

local_user=$(whoami)
repo_url="https://github.com/noplanb/tbm-server"
revision=$(git rev-parse HEAD)
branch=$(git rev-parse --abbrev-ref HEAD)
commit_url="${repo_url}/commit/${revision}"
revision_short=${revision:0:8}

common_text="branch \`${branch}\` <${commit_url}|${revision_short}> of ${application} to *${environment}* [${eb_environment}]"
started_text="${local_user} has started deploying ${common_text}"
failed_text="${local_user} failed to deploy ${common_text}"
finished_text="${local_user} has finished deploying ${common_text}"

# Deploy command

if [ ${environment} == "test" ]; then
  deploy_cmd="true"
else
  deploy_cmd="eb deploy ${eb_environment}"
fi

# Commands

notify_slack "${started_text}"
echo ${deploy_cmd}
if ${deploy_cmd}; then
  notify_rollbar
  notify_slack "${finished_text}" good
else
  notify_slack "${failed_text}" danger
fi
