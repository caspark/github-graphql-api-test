#!/usr/bin/env bash

if [ -z "$GITHUB_API_TOKEN" ]; then
    echo "Missing Github API token - set GITHUB_API_TOKEN environment variable first"
    exit 1
fi

# option 1: ugly one-liner query, because json strings can't be multiline and quotes need to be escaped inside the query
curl 'https://api.github.com/graphql' -H "Authorization: bearer ${GITHUB_API_TOKEN}" -H 'accept: application/vnd.github.starfire-preview+json' -d '{
    "variables": {
        "title": "variable test 123"
    },
    "query": "mutation ($title: String!) { createIssue(input: { repositoryId: \"MDEwOlJlcG9zaXRvcnkxNzM2MjI2NTg\", title: $title, body: \"some body\"}) { issue { url }}}"
}'
