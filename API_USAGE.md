# Querying the CLARIAH Tool Store for integration in other software

## Introduction

Anybody can freely query all harvested information made available through the CLARIAH Tool Store.
The information is offered as linked open data, we therefore assume the reader has experience with
technologies like RDF, JSON-LD and SPARQL.

Clients should take care to query *regularly* as the information is automatically harvested at
regular intervals, and may update.

Our software metadata adheres to the [CLARIAH Software Metadata
Requirements](https://github.com/CLARIAH/clariah-plus/blob/main/requirements/software-metadata-requirements.md).
This document provides a specification of how end-users (developers) should specify their metadata.
It is required reading for anybody who wants to query the data, as it explains how the data is
structured and what vocabularies are used. Some summary notes to recapitulate how our data is
structured:

* The software's source code is always the primary target of the metadata. It described with class
  `schema:SoftwareSourceCode`. We follow the [codemeta](https://codemeta.github.io) standard, which
  builds upon schema.org.
* The metadata describes a specific version of the source code (unless this is not possible)
* Source code links to target products (applications or services) via `schema:targetProduct`. Each
  target product has a specific type corresponding to the interface it offers (e.g. command line,
  web application, web api, desktop application, etc). These are generally described more minimally
  than on source code level, because the source code properties typically apply to all.
* Software metadata is validated against the [Software Metadata Requirements](https://github.com/CLARIAH/clariah-plus/blob/main/requirements/software-metadata-requirements.md), an automatic validation
  report is produced and included with the metadata (via `schema:review`), a rating on a scale
  from 0 (very bad compliance) to 5 (perfect compliance) is encoded in `schema:reviewRating`. We
  recommend CLARIAH to use >= 3 as a threshold for inclusion in researcher-facing portals like Ineo.
* Some of the vocabulary decisions were made to align with CLARIAH efforts like Ineo, most notably
  the TaDiRaH vocabulary, NWO research fields vocabulary, both of which are used for categorization.
  Most other vocabularies were decided to align with other industry standards

When using our data as a source in another portal, a common use-case is to enrich it with further
information, possibly provided by a human editor (some call this side-loading). This is a valid
practice, but we do want to warn against two important pitfalls:

1. Do not enrich tools with information with could/should have been in the metadata harvesting pipeline itself. 
2. Do not correct metadata that should be be corrected within the metadata harvesting pipeline itself.

Falling for either of these would violate two major design principles of what we've been trying to set up:

* Tool producers/providers retain full authorship of their metadata
* Automatic harvesting ensures metadata is as complete and up to date as possible

Tool producers/providers learn how to provide metadata by following the [CLARIAH Software Metadata
Requirements](https://github.com/CLARIAH/clariah-plus/blob/main/requirements/software-metadata-requirements.md)
and our [Contribution
Guidelines](https://github.com/CLARIAH/tool-discovery/blob/master/CONTRIBUTING.md), the latter also
address some frequently asked questions that may be relevant.

## Retrieving full metadata records

Each resource in the tool store can be retrieved as JSON-LD, Turtle or HTML, the former is the
canonical serialisation, the latter is how it is visualised for end-users in a web browser by
default. You can use content negotiation to retrieve an entire resource:

```
$ curl --header "Accept: application/ld+json" -L https://tools.clariah.nl/frog
```

A graph of all data can also be obtained, this will contain a `@graph` field under which all
`SoftwareSourceCode` instances can be found in expanded form:

```
$ curl --header "Accept: application/ld+json" -L https://tools.clariah.nl
```

Although it is recommended to use JSON-LD and RDF-aware technologies, the canonical serialisation is
uniform enough for you to consider just using simple JSON parser and extraction. Most notably:

* All nodes are fully expanded in the JSON-LD representation. This leads to a fair degree of duplication/redundancy but makes parsing easier.
* The JSON-LD context is fixed.
* The data is enriched with information from other vocabularies. 

When you do use a simple JSON parser, do take into account that many RDF properties may occur more
than once, so that you need to take into account that an item is either a list or a singleton
(primitive or json object).

## Querying

We offer a [SPARQL endpoint](https://tools.clariah.nl/api/sparql) (with a [YASGUI web
interface](https://tools.clariah.nl/api/) for interactive experimentation). This is the main
interface to query the tool store unless you opt to parse the JSON-LD directly as mentioned above.

In this section we will mainly provide some example SPARQL queries. We define here, once, the
prefixes for all the possible namespaces/vocabularies that may occur in these queries:

```sparql
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX schema: <http://schema.org/>
PREFIX codemeta: <https://codemeta.github.io/terms/>
PREFIX softwaretypes: <https://w3id.org/software-types#>
PREFIX softwareiodata: <https://w3id.org/software-iodata#>
PREFIX trl: <https://w3id.org/research-technology-readiness-levels#>
PREFIX repostatus: <https://www.repostatus.org/#>
PREFIX nwo: <https://w3id.org/nwo-research-fields#>
PREFIX tadirah: <https://vocabs.dariah.eu/tadirah/>
PREFIX spdx: <http://spdx.org/licenses/>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
```

### Query for a list of all tools

To get a list of all tools:

```sparql
SELECT ?res WHERE {
  ?res rdf:type schema:SoftwareSourceCode .
} 
```

### Query by metadata validation rating 

To get a list of tools with a minimal metadata validation rating of 3:

```sparql
SELECT ?res ?rating WHERE {
  ?res rdf:type schema:SoftwareSourceCode .
  ?res schema:review ?review .
  ?rating schema:reviewRating ?rating .
  FILTER (?rating >= 3)
} 
```

### Query by repostatus

To get a list of tools with development status 'active' or 'inactive' according to repostatus. This
filters out tools that are clearly concepts, work in progress, abandoned or suspended and should return a fair selection of usable
tools for end users.

```sparql
SELECT ?res ?status WHERE {
  ?res rdf:type schema:SoftwareSourceCode .
  ?res codemeta:developmentStatus ?status .
  FILTER (?status = repostatus:active || ?status = repostatus:inactive) 
} 
```

