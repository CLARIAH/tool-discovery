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

## Execution

docker build -t codemeta-server-tool .
docker run -itd -p 80:80 --env-file=my-env.env --name=cm-srv -v codemeta_volume:/tool-store-data --restart=unless-stopped codemeta-server-tool 

Local yamls for sources harvesting: add to run -v $PWD/source-registry/:/usr/src/source-registry/source-registry/ and set LOCAL_SOURCE_REGISTRY=true in my-env.env

Event-based collection is always On. POST your codemeta.json file with curl -u <nginx-user> -XPOST -H "Content-Type: application/json" -dcodemeta.json -u user <url>/rest/

For private git repo add to docker run -e  GIT_USER='youruser' -e GIT_PASSWORD='yourtoken'
To clean up remove the volume codemeta_volume