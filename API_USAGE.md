# Querying the CLARIAH Tool Store for integration in other software

Anybody can freely query all harvested information made available through the CLARIAH Tool Store. The information is offered as linked open data, we therefore assume the reader has experience with technologies like RDF, JSON-LD and SPARQL.

Clients should take care to query *regularly* as the information is automatically harvested at regular intervals, and may update.

Our software metadata adheres to the [CLARIAH Software Metadata Requirements](https://github.com/CLARIAH/clariah-plus/blob/main/requirements/software-metadata-requirements.md). This document provides a specification of how end-users (developers)
should specify their metadata. It is also required reading for anybody who wants to query the data, as it explains how the data is structured and what vocabularies are used.

Each resource in the tool store can be retrieved as JSON-LD or Turtle, the former is the canonical serialisation. You can use content negotiation to retrieve a resource:

```
$ curl --header "Accept: application/ld+json" -L https://tools.clariah.nl/frog
```

A graph of all data can also be obtained:

```
$ curl --header "Accept: application/ld+json" -L https://tools.clariah.nl
```

Although it is recommended to use JSON-LD and RDF-aware technologies, the canonical serialisation is uniform enough for you to consider a just using simple JSON parser and extraction. Most notably:

* All nodes are fully expanded in the JSON-LD representation. This leads to a fair degree of duplication/redundancy but makes parsing easier.
* The JSON-LD context is fixed.
* The data is enriched with information from other vocabularies. 

We offer a [SPARQL endpoint](https://tools.clariah.nl/api/sparql) (with a [YASGUI web interface](https://tools.clariah.nl/api/) for interactive experimentation). This is the main interface to query the tool store unless you opt to parse the JSON-LD directly as mentioned above.
