#!/bin/bash

# Functions

notify_slack() {
  local webhook_url="https://hooks.slack.com/services/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"
  local branch=$(git rev-parse --abbrev-ref HEAD)
  local commit_url="${repo_url}/commit/${revision}"
  local revision_short=${revision:0:8}
  local common_text="branch \`${branch}\` <${commit_url}|${revision_short}> of ${application} to *${environment}* [${eb_environment}]"
  local started_text="${local_user} has started deploying ${common_text}"
  local failed_text="${local_user} failed to deploy ${common_text}"
  local finished_text="${local_user} has finished deploying ${common_text}"

  local event=$1
  local text
  local color

  case ${event} in
    started)
      text=${started_text}
      ;;
    finished)
      text=${finished_text}
      color=good
      ;;
    failed)
      text=${failed_text}
      color=danger
      ;;
    *)
      echo "Unknown event ${event}, valid events are started, finished, failed"
      exit 1
      ;;
  esac

  local payload="payload={\"attachments\": [{\"color\": \"${color}\", \"text\": \"${text}\", \"mrkdwn_in\": [\"text\"] }]}"

  echo -n "Notify slack for ${event} ... "
  if [ ${environment} == "test" ]; then
    echo "ok"
    echo "${payload}"
  else
    curl -X POST --data-urlencode "${payload}" ${webhook_url}
    echo
  fi
}

notify_rollbar() {
  local rollbar_username=${local_user}
  local comment=$1
  echo "Notify Rollbar: ${comment}"
  if [ ${environment} == "test" ]; then
    echo https://api.rollbar.com/api/1/deploy/ \
      -F access_token=${rollbar_access_token} \
      -F environment=${environment} \
      -F revision=${revision} \
      -F local_username=${local_user} \
      -F rollbar_username=${rollbar_username} \
      -F comment=${comment}
  else
    curl https://api.rollbar.com/api/1/deploy/ \
      -F access_token=${rollbar_access_token} \
      -F environment=${environment} \
      -F revision=${revision} \
      -F local_username=${local_user} \
      -F rollbar_username=${rollbar_username} \
      -F comment=${comment}
  fi
  echo
}

# Variables

application="zazo"
environment=$1
[ -z ${environment} ] && environment=${RACK_ENV}
[ -z ${environment} ] && environment="playground"
case ${environment} in
  production) eb_environment="${application}-prod2-0-1"
    ;;
  *) eb_environment="${application}-${environment}"
    ;;
esac

local_user=$(whoami)
repo_url="https://github.com/noplanb/tbm-server"
revision=$(git rev-parse HEAD)

# Deploy command

if [ ${environment} == "test" ]; then
  deploy_cmd="true"
else
  deploy_cmd="eb deploy ${eb_environment}"
fi

# Commands

echo "Deploy command: ${deploy_cmd}"
notify_slack started
if ${deploy_cmd}; then
  notify_slack finished
  notify_rollbar $2
else
  notify_slack failed
fi
