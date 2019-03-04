Mutation test
=============

To get an idea of the developer experience for Statuspage customers if Statuspage were to build a GraphQL API, I set myself a task of creating a file in a branch using Github's GraphQL API, as they are the posterchild of GraphQL.

Prior to this exercise, I had read a lot about GraphQL so I was aware of many overarching concepts, however I had spent very little time actually working with a GraphQL API (basically some tiny amount of time playing with the autocomplete and schema explorer in the Graphiql editor).

So this should be a decent approximation of how an experienced web developer with little practical GraphQL experience fairs

How did it go?
--------------

I spent about 15 minutes reading docs and exploring the API, but quickly realized that Github didn't seem to have a GraphQL API for creating commits (yet? queries exist but mutations are missing). So I pivoted to creating an issue in a repository whose name I knew (i.e. lookup repo by name, create issue with datetime in title); realistically this is more similar to creating an Incident after first looking up a Statuspage by title.

I succeeded and it took me ~1h20m to implement this in Python complete with basic error handling, using no existing GraphQL libraries. It probably would've been 5-15 mins faster if I hadn't been taking detailed notes. Where was that time spent?

* My first 30m was spent dealing with Github's issue mutation API still being in preview; they've decided that extra headers need to be passed to enable preview APIs, but have not set up their API explorer to handle that. I worked around this by downloading [GraphQL Playground](https://github.com/prisma/graphql-playground) (a tool I had read about) and adding the necessary header there.
* I spent about 15m in the playground, exploring the schema and writing my queries & mutations.
* 15m reading and experimenting to understand how graphql is encoded on the wire, split across understanding how to query, how to mutate, how to specify variables and how to check for errors
* 20m generic writing/refactoring/debugging Python code: futzing with the http library, remembering how to drop to a shell, get envvars, etc

I intentionally did not spend much time reading Github's documentation unless I got stuck (as I wanted to be in the mindset of the impatient developer), and likewise intentionally did not try to use any pre-existing Python libraries for GraphQL. 

Takeaways
---------

* Some of Github's GraphQL API is not yet complete: some parts are still in preview, and e.g. there doesn't seem to be any way to create commits.
* The **header-based preview mechanism of the Github API hurts the API's usability**: it works, but hiding the parts of the API that are covered by it makes it harder to find out if an API can or can't do something using the Graphiql query editor. This was so annoying it almost turned me off this mini project.
  * A relatively quick fix would be to allow users to opt into experimental APIs right inside Graphiql (it's a question of setting some extra headers on the GraphQL request).
* I **missed having an overview of the important nouns**. If I had known about it before, I would've liked to have used https://apis.guru/graphql-voyager/ , but even a guide to common operations would've been nice.
* The Graphiql editor & schema explorer (and GraphQL Playground, which is based on it) are really polished and provide a really nice experience for quickly testing out queries: good error messages, autocomplete, syntax highlighting, error underlining (and the server-side sends back really nice errors too). **I found myself enjoying and looking forward to crafting my queries.**
* A "Copy as Curl" from the graphiql interface would've saved me a decent amount of time in understanding how GraphQL was encoded on the wire, which would've made it easier for me to implement my Python client from scratch, however, **once I understood the wire protocol, it was very easy to implement.**
  * A quick win here would be telling people to open up the dev tools, but it'd be even nicer to contribute "copy as curl" to Graphiql.
* **Having GraphQL posted to the server as JSON is mildly annoying** because you need to escape quotes in GraphQL strings and JSON doesn't support multiline strings.
  * After I completed this project, I put together several bash scripts to create an issue, much like a customer might create an Incident from a bash script (see `create-issue-*.sh`); you end up having to trade off between succintness, multiline queries, comprehensibility and ability to access shell variables. The best option is probably `create-issue-readable.sh`, but due to having to deal with string quoting **GraphQL is less usable in shell scripts than a `curl -X POST` with a couple of data args**.
  * A workaround for this might be to support sending raw GraphQL queries in the POST (presuming it's allowed by the spec and we can think of a way to allow graphql variables to be included) instead of wrapping the query in JSON strings.
  * Variations of curl such as [graphqurl](https://github.com/hasura/graphqurl) might help out here, but they will still be an extra thing to install.

Overall, my experience is that it's a bit more effort to get set up to hit a GraphQL API, but a good experience once you're going.

Raw notes & log
---------------

1155 create github repo and python scaffolding for making http requests

1200 start exploring github api for a "create file mutation"

1205 doesn't seem to be there, look through their guides. 

1210 not there either, revert to googling - seems to be possible although very convoluted with an older api. hmm, maybe this was a poor task to choose?

1215 decide to switch tact to creating an issue instead - this is closer to an incident creation anyway

1220 no sign of issues API in the graphql explorer. Turns out issues API is under preview release; not being able to see preview releases in the API explorer is frustrating

1225 download and try to set up GraphQL Playground to work around this, spend 3 mins getting it working on linux. Now have to plug in endpoint URL, which doesn't seem to be obvious on graphicl? from https://developer.github.com/v4/public_schema/ I found https://developer.github.com/v4/public_schema/schema.public.graphql but that didn't work in the playground tool, so it's probably wrong. Look at graphicl in devtools and see https://graphql-explorer.githubapp.com/graphql/proxy get used, try to use that, get rejected. Playground is an electron app so check and notice that it's 422ing, probably wrong endpoint again.

1230 finally find https://api.github.com/graphql at bottom of https://developer.github.com/v4/guides/intro-to-graphql/ , obvious in hindsight, but auth still required.

1235 find docs on making an api token, make one with scopes that seems reasonable https://i.imgur.com/LCr2ldi.png , make a successful curl request

1240 loaded up schema successfully in playground after spending a while hunting for how to add an auth header

1245 need to add the header to have the issue mutation appear in the preview, add `"Accept": "application/vnd.github.starfire-preview+json"` header and it works like a charm. start exploring issue schema, get to:

```
mutation {
  createIssue(input: { repositoryId: ??? })
}
```

looks like we need to pass in an issue input somehow, which needs a repo id - switch to figuring out how to get that

1250 wrote query to get that in 1 min - autocomplete was awesome here, i just guessed my way to the end:

```
query {
  repository(owner: "caspark", name: "github-graphql-api-test") {
    name, id
  }
}
```

now have the ID of MDEwOlJlcG9zaXRvcnkxNzM2MjI2NTg, plug that in to the mutation, and we need more fields like title (error in the editor tells me that), open up the API docs and search for CreateIssueInput (which i got from the hover), specify the title and the error goes away.

1255 get told that createIssue must select subfields, update to syntax suggested by the error, do it, tweak some more, end up with

```
mutation {
  createIssue(input: { repositoryId: "MDEwOlJlcG9zaXRvcnkxNzM2MjI2NTg", title: "test 1", body: "some body"}) {
    issue {
      id
    }
  }
}
```

run it, it works first time, double check the issue was actually made - it was!

1300 break for lunch

1330 back from lunch, let's get this into my python script. spend 15 mins futzing about with requests lib to set headers, store the graphql query properly, remembering how to debug python code, etc.

1345 realize i need to send a valid json body, as https://developer.github.com/v4/guides/forming-calls/ says. Doh. Could've figured that out a lot faster by looking at the request the playground makes.

1350 spend 10 mins writing a basic abstraction to send graphql queries, because somewhat annoyingly the format for a graphQL query is

```
query {
  repository(owner: "caspark", name: "github-graphql-api-test") {
    name
    id
  }
}
```

but its minimal wire equivalent is json:

```
{"query":"{\n  repository(owner: \"caspark\", name: \"github-graphql-api-test\") {\n    name\n    id\n  }\n}\n"}
```

1400 python program gets a successful response back from github api, parse out the id, ignoring error handling for now. now let's mutate

1415 spend a few mins refactoring little script to make mutations fit in cleanly, only to figure out that mutations are sent under "query:" on the wire as well, but wrapped in "mutation { ... }" on the wire. Well, that makes things easier but it means my refactoring was unnecessary - should have looked at the graphql wire format first.

1420 mutation to create an issue works first time, now let's insert the date & time into the title, i'm sure i could hardcode it in the title or use python string substitutions, but i remember seeing something about variables on the github API docs

1425 write some python code to do this, think better of it and prototype inside the playground, quickly realize that graphql variables can't be inside strings thanks to good error messages from graphql (variables can't be unused), refactor python code slightly to handle this. 

1430 it works, implement error handling for graphql queries & mutations, takes 2 lines to detect errors - same as REST, which is nice.

1435 fin.

