# Contributing Guidelines

## Adding your own software to be harvested

To harvest and collect metadata from various projects, you need to create configuration files that tells the harvester
where to look. These are simple ``yaml`` configuration files that reside in the [CLARIAH tool source registry](https://github.com/CLARIAH/tool-discovery/tree/master/source-registry), one for each tool to harvest. Please add your yaml configurations there via a [pull request](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/proposing-changes-to-your-work-with-pull-requests/creating-a-pull-request). The YAML file has the extension ``.yml`` and takes the following format:

```yaml
source: https://github.com/user/repo
services:
    - https://example.org
```

The ``source`` property specifies a **single** source code repository where the source code of the tool lives. This must
be a *git* repository that is publicly accessible.  Note that you can specify only one repository here, choose the one
that is representative for the software as a whole.

The ``services`` property lists zero or more URLs where the tool can be accessed as a service. This may be a web application, simple webpage, or some other form of webservice. For webservices, rather than enumerate all service endpoints individually, this should be pointed to a URL that provides itself provides a specification of endpoints, for example a URL serving a [OpenAPI](https://www.openapis.org/) specification. The information provided here will be expressed in the resulting `codemeta.json` through the ``targetProduct`` schema.org property as described in issue [codemeta/codemeta#271](https://github.com/codemeta/codemeta/issues/271). This links the source code to specific instantiations of the software.

Additional properties you may specify in your yaml file:

* ``root`` - The root path in the source code repository where to look for metadata. This can be set if the tool lives
    as a sub-part of a larger repository. Defaults to the repository root.
* `scandirs` - List of sub directories to scan for metadata, in case not everything lives in the root directory.
* `ref` - The git reference (a branch name of tag name) to use. You can set this if you want to harvest one particular
    version. **If not set, codemeta-harvester will check out the latest
    version tag by default** (this assumes you use some kind of semantic versioning for your tags). Only if no tags are present at all, it falls back to using the `master` or `main` branch directly.
