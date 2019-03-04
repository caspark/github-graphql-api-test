"""
A no-graphql-libraries implementation of fetching a repo by name and creating an issue in it with the current date & time.

To run, do
pipenv install
pipenv run python main-original.py
"""

import datetime
import json
import requests
import os
import pprint

# curl -H "Authorization: bearer c8a1a721ba9150027aad31001a360e253e7fd52d" https://api.github.com/graphql
GITHUB_API_TOKEN = os.environ.get('GITHUB_API_TOKEN')
if not GITHUB_API_TOKEN:
    raise ValueError("API token not specified; set the GITHUB_API_TOKEN environment variable to your Github API token")

QUERY_FIND_REPO_ID = """
query {
    repository(owner: "caspark", name: "github-graphql-api-test") {
        id
    }
}
"""

MUTATION_CREATE_ISSUE = """
mutation($title: String!) {
  createIssue(input: { repositoryId: "MDEwOlJlcG9zaXRvcnkxNzM2MjI2NTg", title: $title, body: "some body"}) {
    issue {
      url
    }
  }
}
"""


def graphql(query_or_mutation_string, variables={}):
    body = json.dumps({
        'query': query_or_mutation_string,
        'variables': variables
    })
    print("Making request of %s" % body)
    r = requests.post('https://api.github.com/graphql', data=body, headers={
        'Content-Type': 'application/json',
        'Accept': 'application/vnd.github.starfire-preview+json',
        'Authorization': 'Bearer %s' % GITHUB_API_TOKEN
    })
    r_json = r.json()
    print("JSON response was", pprint.pformat(r_json))
    if r_json.get('errors'):
        raise ValueError("GraphQL request error; error follows:\n%s" % pprint.pformat(r_json['errors']))
    return r_json['data']


def main():
    repo_id = graphql(QUERY_FIND_REPO_ID)['repository']['id']
    print("Found repo of", repo_id)

    issue_url = graphql(MUTATION_CREATE_ISSUE, {
        'title': 'Test issue: %s' % datetime.datetime.now()
    })['createIssue']['issue']['url']
    print("Made issue of", issue_url)


if __name__ == "__main__":
    main()