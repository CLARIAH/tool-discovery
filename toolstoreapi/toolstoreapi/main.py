import sys
from os import environ
from rdflib_endpoint import SparqlEndpoint

from rdflib import Graph

example_query = """Example query:\n
```
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
SELECT * WHERE {
  ?sub ?pred ?obj .
} LIMIT 100
```"""

try:
    BASEURL = environ['BASEURL']
except KeyError:
    print("Environment variable $BASEURL must be set",file=sys.stderr)
    sys.exit(2)

try:
    TOOLSTORE_DATA = environ['TOOLSTORE_DATA']
except KeyError:
    print("Environment variable $TOOLSTORE_DATA must be set (to a JSON-LD file usually called all.json)",file=sys.stderr)
    sys.exit(2)


g = Graph()
g.parse(file=open(TOOLSTORE_DATA,'rb'), format="json-ld")

# Start the SPARQL endpoint based on the RDFLib Graph
app = SparqlEndpoint(
    graph=g,
    title="SPARQL endpoint for CodeMeta Tool Store",
    description="A SPARQL endpoint to serve software metadata using codemeta and schema.org\n[Source code](https://github.com/CLARIAH/tool-discovery/)",
    version="0.1.0",
    public_url=f"{BASEURL}/api/sparql",
    cors_enabled=True,
    example_query=example_query
)

## Uncomment to run it directly with python app/main.py
# if __name__ == "__main__":
#     import uvicorn
#     uvicorn.run(app, host="0.0.0.0", port=8000)
