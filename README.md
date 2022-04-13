# CLARIAH Tool Discovery

This repository contains everything related to tool discovery and software metadata in CLARIAH.
* `Dockerfile`:  The docker container for the CLARIAH Tool Discovery pipeline, including both the
    [harvester](https://github.com/proycon/codemeta-harvester) and the [server and
    API](https://github.com/proycon/codemeta-server) powering the CLARIAH Tool Store.
* `source-registry/`: The tool source registry, contains the source repositories locations and service endpoints for all
    CLARIAH tools. **This is open for [contributions](CONTRIBUTING.md)**
* ``etc/``, ``static/``: supporting files for the deployment at
* ``legacy/cmdi/``: Contains legacy CMDI metadata as gathered in WP3 task MD4T at Utrecht University

## Service

The tool discovery service, consisting of a harvester that runs on regular intervals (each night) and a tool store,
is deployed at https://tools.clariah.nl (production) and https://tools.dev.clariah.nl (development).

All harvested data is also available as individual files via https://tools.dev.clariah.nl/files/

## Links

* [Tool Discovery kanban board](https://github.com/orgs/CLARIAH/projects/1) - Project planning

