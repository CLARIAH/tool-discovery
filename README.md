[![GitHub build](https://github.com/CLARIAH/tool-discovery/actions/workflows/shacl.yml/badge.svg?branch=master)](https://github.com/CLARIAH/tool-discovery/actions/)
[![Project Status: Active -- The project has reached a stable, usable state and is being actively developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)

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
* [CLARIAH Tool Discovery Presentation](https://diode.zone/w/7Urqq1xdqMFDV24CRConXk) - Presented at CLARIAH Tech Day

## Usage

For CLARIAH (local development):

```
docker build -t clariah-tool-discovery .
docker run -itd -p 8080:80 --env-file=local-dev.env --name=cm-srv -v codemeta_volume:/tool-store-data --restart=unless-stopped clariah-tool-discovery 
```

We recommend you to also pass an extra ``--env GITHUB_TOKEN=..........`` or you will likely hit GitHub's API rate limit during harvesting.

More generic:

```
docker build -t codemeta-server-tool --build-arg nginx_pass=some_password .
docker run -itd -p 80:80 --env-file=my-env.env --name=cm-srv -v codemeta_volume:/tool-store-data --restart=unless-stopped codemeta-server-tool 
```

To use local yamls for sources harvesting (rather than a remote git repo); add to run ``-v $PWD/source-registry/:/usr/src/source-registry/source-registry/`` and set ``LOCAL_SOURCE_REGISTRY=true`` in ``my-env.env``.

Event-based collection, i.e. allowing clients to pushing codemeta files, can be enabled by setting ``--env-arg UPLOADER=true``, you can then POST your codemeta.json file with ``curl -u <nginx-user> -XPOST -H "Content-Type: application/json" -dcodemeta.json -u user <url>/rest/``

For private git repo add to ``docker run -e  GIT_USER='youruser' -e GIT_PASSWORD='yourtoken'``
To clean up remove the volume ``codemeta_volume``
