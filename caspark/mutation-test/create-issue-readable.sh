#!/usr/bin/env bash

if [ -z "$GITHUB_API_TOKEN" ]; then
    echo "Missing Github API token - set GITHUB_API_TOKEN environment variable first"
    exit 1
fi

# option 2: build the graphql query by escaping quotes, then fire off the request
readonly CREATE_ISSUE_MUTATION=$(sed 's/"/\\"/g' <<'GRAPHQL'
mutation($title: String!) {
  createIssue(input: { repositoryId: "MDEwOlJlcG9zaXRvcnkxNzM2MjI2NTg", title: $title, body: "some body"}) {
    issue {
      url
    }
  }
}
GRAPHQL
)

curl 'https://api.github.com/graphql' -H "Authorization: bearer ${GITHUB_API_TOKEN}" -H 'accept: application/vnd.github.starfire-preview+json' -d @- <<HTTP_BODY
{
    "variables": {
        "title": "variable test 123"
    },
    "query": "$CREATE_ISSUE_MUTATION"
}
HTTP_BODY
