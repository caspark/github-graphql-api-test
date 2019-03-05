#!/usr/bin/env bash
set -eu

#export GITHUB_AUTH_TOKEN=<personal auth token>
export DATE=`date -u +'%Y-%m-%d %H:%M:%S'`
curl -X POST -d "{\"query\": \"mutation {createIssue(input:{repositoryId: \\\"MDEwOlJlcG9zaXRvcnkxNzM2MjI2NTg=\\\", title: \\\"$DATE\\\"}) {issue {url } } }\"}" -H "Accept: application/vnd.github.starfire-preview+json"  -H "Authorization: bearer $GITHUB_AUTH_TOKEN" https://api.github.com/graphql 