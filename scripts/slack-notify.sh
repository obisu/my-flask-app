#!/usr/bin/env bash
set -e

if [ -z "$SLACK_WEBHOOK_URL" ]; then
  echo "SLACK_WEBHOOK_URL is not set"
  exit 1
fi

STATUS="$1"
MESSAGE="$2"

payload=$(cat <<JSON
{
  "text": "*${STATUS}* - ${MESSAGE}"
}
JSON
)

curl -X POST -H 'Content-type: application/json' \
  --data "${payload}" \
  "${SLACK_WEBHOOK_URL}"
