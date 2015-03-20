#!/bin/sh
environment=$1
[ -z ${environment} ] && environment=${RACK_ENV}
[ -z ${environment} ] && environment="production"
curl -X POST --data-urlencode "payload={\"text\": \"Deploying Zazo *${environment}* environment\", \"channel\": \"#general\", \"username\": \"Elasticbeanstalk\", \"icon_url\": \"https://cdn2.iconfinder.com/data/icons/amazon-aws-stencils/100/Deployment__Management_copy_Elastic_Beanstalk-64.png\"}" https://hooks.slack.com/services/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
