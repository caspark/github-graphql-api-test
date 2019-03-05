
3:00 google graphql + github; read through https://developer.github.com/v4/guides/intro-to-graphql/ and associated docs
3:25 run first introspection query using graphql explorer, https://developer.github.com/v4/explorer/
3:29 ditto, with curl
 - can't prettify graphql query in my text editor, mildly annoying
3:40
 - very annoyed at JSON parsing problems and lexical errors with curl, switched to using graphql explorer
 - variable substitution sounds like a really cool feature missing from REST
4:00 go back and re-read docs on edges and nodes
4:45 need to write a mutation to create an issue
 - createIssue mutation looks promising
  - needs assigneeIds, labelIds, projectIds, title
  - returns issue; can I get this to return the url?

  mutation CreateIssueWithTimestamp {
    createIssue(input:{assigneeIds:[], labelIds: [], projectIds:[], title: "Vincent was here"}) {
      issue {
        url
      }
    }
  }

4:53 need to write query to figure out projectIds (don't care about assignees or labels)
 - repository -> projects -> [edges] -> project node -> id

  query FindIds {
    repository(owner:"caspark", name:"github-graphql-api-test") {
      projects(search:"github-graphql-api-test", first:20) {
        edges {
          node {
            id
          }
        }
      }
    }
  }

5:08 nope, empty response
5:18 wait no, CreateIssueInput takes in a repositoryId as well, query for that instead

  query FindIds {
    repository(owner:"caspark", name:"github-graphql-api-test") {
      id
    }
  }

  {
    "data": {
      "repository": {
        "id": "MDEwOlJlcG9zaXRvcnkxNzM2MjI2NTg="
      }
    }
  }

5:21 createIssue mutation should have everything necessary?
 - can't use graphql explorer with preview APIs, urgh

  $ curl -X POST -d @/Users/vcheng2/Downloads/request.json -H "Authorization: bearer 139aa1d71d51bdf5202b7e22576542074b470843" https://api.github.com/graphql

  {
      "mutation": "mutation CreateIssueWithTimestamp {
    createIssue(input:{repositoryId: \"MDEwOlJlcG9zaXRvcnkxNzM2MjI2NTg=\", title: \"Vincent was here\"}) {
      issue {
        url
      }
    }
  }"
  }

  {"errors":[{"message":"A query attribute must be specified and must be a string."}]}
  ???

5:35 curl json request body and graphql explorer syntax slightly different?



