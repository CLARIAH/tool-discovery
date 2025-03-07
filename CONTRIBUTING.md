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

The ``services`` property lists zero or more URLs where the tool can be accessed as a service. This may be a web application, simple webpage, or some other form of webservice. For webservices, rather than enumerate all service endpoints individually, this should be pointed to a URL that itself provides a specification of endpoints, for example a URL serving an [OpenAPI](https://www.openapis.org/) specification. The information provided here will be expressed in the resulting `codemeta.json` through the ``isSourceCodeOf`` codemeta property (see also <https://softwareunderstanding.github.io/software_types/>). This links the source code to specific instantiations of the software.

Additional properties you may specify in your yaml file:

* ``root`` - The root path in the source code repository where to look for metadata. This can be set if the tool lives
    as a sub-part of a larger repository. Defaults to the repository root.
* `scandirs` - List of sub directories to scan for metadata, in case not everything lives in the root directory.
* `ref` - The git reference (a branch name of tag name) to use. You can set this if you want to harvest one particular
    version. **If not set, codemeta-harvester will check out the latest
    version tag by default** (this assumes you use some kind of semantic versioning for your tags). Only if no tags are present at all, it falls back to using the `master` or `main` branch directly.
* `tagprefix` - A prefix used for the git tags (only applicable in edge cases), the last part of the tag must still comply to a semantic versioning scheme.
* `tagignore` - A regular expression (`grep -E`) of git tags to ignore (only applicable in edge cases), by default tags with "alpha" will be ignored.

## Frequently Asked Questions and Troubleshooting

### Q: What is CLARIAH software? I'm not sure if my software qualifies to register here.

**A:** Please see [point 2 of the Software Metadata Requirements](https://github.com/CLARIAH/clariah-plus/blob/main/requirements/software-metadata-requirements.md#2-all-tools-must-be-registered-in-the-tool-store-registry) for an answer to this question.

### Q: Can I specify multiple source code repositories?

**A:** No, each codebase by definition has its own metadata entry. It is very
well possible that a complex piece of software consists of multiple interacting
components, each in a kind of dependency relation with the others, and that
each of those is described by a different source code repository. In fact,
from a reusability/modularity perspective this is even recommended over large
monolithical code repositories.

Relations between different components should be explicitly modelled in the
software metadata as dependencies.

Consider the following analogy: we describe software from the source like water
springs from sources and flows through rivers to the sea. Streams may merge
(dependency relations) and lead to more complex software. To get the complete
picture, all sources must be described.

### Q: I have a monolithical code repository with multiple components? Can I make multiple entries using the same repo?

**A:** Yes, use the ``scandirs`` option to point to a path inside the repo
where metadata should be harvested.

### Q: I have a service and multiple source code repositories, with what codebase do I associate the service?

**A:** It's common and best practise to separate frontend and backend
components into two (or more) separate code repositories. You should associate
services (``services:`` in the YAML entry) with the codebase that provides the
actual service interface, i.e. for web applications this is the frontend codebase.

### Q: Can I set or override metadata from the tool source registry?

**A:** No, the source registry only registers software source code and software
service endpoints and deliberately does **not** allow any further metadata. We
follow the principle that metadata should be specified and controlled *at the
source* by the developers/producers/providers, and not by any intermediate
party. This way we always give authors of the software and providers of a
software service full authorship over their metadata.

### Q: My software is a service and has no (public) source code repo, can I add it?

**A:** Having no public source code repository violates the CLARIAH Software
Requirements, hinders open source contributions and scientific reproducibility,
and is therefore  *strongly discouraged*. Nevertheless, it is possible to
register YAML entries in the source registry with only the ``services:``
property and without a ``source:`` property. Note that metadata harvesting will
then be severely limited, especially if the web endpoint itself doesn't provide
explicit metadata.

The only use-cases in which this is acceptable is if your web application is
just a deployment of some generic third party software entirely unrelated to
CLARIAH (e.g. some popular CMS software like Drupal or Wordpress qualifies) and
has no real custom implementations whatsoever. Do consider whether what you're
describing still qualifies as a tool rather than just being an informational
website (which is out of scope as an endpoint for this registry).

### Q: How can I inspect the quality of my metadata and improve it?

**A:** All metadata is automatically validated. There are two aspects you should check in the [CLARIAH tool
store](https://tools.dev.clariah.nl) for your software (click the title of your tool to go to it's page):

1. Are there any harvesting errors? If so, check the harvest log (see next section)
    * Errors occur if the harvester fails to extract something
2. Look at the ranking your software metadata gets (0 to 5 stars) and inspect the validation report (click the validation stars).
    * Three degrees of severity are distinguished: violations, warnings and informational notices. All are formulated in reference to the [CLARIAH Software Metadata Requirements](https://github.com/CLARIAH/clariah-plus/blob/main/requirements/software-metadata-requirements.md). Consult the descriptions there to learn how to improve your metadata. Make sure to resolve all violations and warnings, it is fine to have some *info* notices in the validation report and you can still get a 4/5 rating that way. No need to obsess over getting to 5/5 if you feel some info notices are not applicable. As a guideline for CLARIAH, aim for at least a 3/5 rating, because other front-end systems like Ineo and the VLO are recommended to use that as a minimum threshold for software they incorporate into their systems.

### Q: Is there a log of the harvest run?

**A:** Go to the page of your tool in the [CLARIAH tool
store](https://tools.dev.clariah.nl) (click the title of your tool in the
index), and at the bottom of the page there is a "Show harvest log" button that
shows the full harvest log. Alternatively, grab it from https://tools.dev.clariah.nl/files/ .

A log of the full harvest run of everything is [available here](https://tools.dev.clariah.nl/files/harvest.log)

### Q: How often is the metadata harvested?

**A:** We currently harvest at 03:00 (CEST) each night. Results should be available about ten to fifteen minutes afterwards (when the full harvest run completes).

### Q: Why can't I see my metadata changes reflected?

**A:** Check the following:

* Has the harvester run passed? (see previous point, also check the dates in the harvest.log if needed)
* Did you make metadata changes to the master/main branch of your codebase? These won't be harvested until you have done a proper release (git tag), because the harvester always chooses the latest stable release.
    * Also check if the proper version is harvested. We require a versioning scheme compatible with semantic versioning (applies to the git tags). Ad-hoc versioning schemes may lead to unexpected results as the harvester is unable to identify which release is the latest.
    * Note that pre-releases (anything with a version suffix like -alpha, -beta, -rc1, -SNAPSHOT etc..) are **NOT** harvested. Only regular releases are (which may still correspond to any development status, development status should always be expressed in the metadata rather than in release versions).
    * If you have no releases at all (discouraged, only acceptable for initial Work-in-Progress repositories), the harvester will simply harvest your master/main branch.
* Check the harvest.log for your tool. There may have been errors during harvesting which should appear in the log (for instance, invalid JSON, network connection problems, etc)

### Q: Why is one of my metadata fields wrong even though I have the correct value?

**A:**  First check the answer given to the above question. If that doesn't solve it, consider the following: 
Our harvester combines metadata from various information sources it can find. It assigns a different priority to each of these sources, determining what values takes precedence in case of a conflict.
The priority is roughly the following:

1. ``codemeta.json``, if this file is provided, the harvest won't look at anything else (aside from the three exceptions mentioned at the end).
2. ``codemeta-harvest.json``
3. ``CITATION.cff``
3. Language specific metadata from ``setup.py``, ``pyproject.toml``, ``pom.xml``, ``package.json`` and similar.
4. files such as `LICENSE`, `MAINTAINERS`, `CONTRIBUTORS`, `AUTHORS`, `README`
5. Information from git (e.g. contributors, git tag for version, date of first/last commit)
6. Information from the github or gitlab API (e.g. project name/description)

Three notable exceptions are:

1. For development status, repostatus badge in the `README.md` *in the git master/main branch* takes precendence over all else (overriding whatever is in codemeta.json!)
2. For maintainers, the parsing of `MAINTAINERS` *in the git master/main branch* is always taken into account (merged with anything in codemeta.json)
3. If the harvester finds a version-specific DOI at Zenodo for your software, it will always use that (overriding whatever is in codemeta.json)

### Q: There are duplicate authors and some of the names or e-mail addresses are wrong. Why?

**A:** If no explicit authors have been specified, our harvester falls back to considering everybody who contributed to the git repository as an author. However, not everybody has their git clients set-up properly, so this may lead to duplicates when people use inconsistent git configurations from multiple systems. To remedy this, set explicit authors in one of the supported ways.

### Q: Can I run the harvester myself to check what the harvester makes of my software?

**A:** Yes, there are two methods. The first assumes you already registered a YAML file for your software with this source registry and will be very similar to how our harvester runs. We use `frog.yml` in this example, substitute it with your own:

```
$ git clone https://github.com/CLARIAH/tool-discovery/
$ cd tool-discovery
$ docker pull proycon/codemeta-harvester
$ docker run -v $(pwd):/data proycon/codemeta-harvester --stdout --validate /data/schemas/shacl/software.ttl /data/source-registry/frog.yml
```

It will output JSON (corresponding to `codemeta.json`) to standard output.

The first method corresponds to how our the harvester is invoked on the CLARIAH server. It means, it will clone *the latest stable release* of your git repository and do the conversion and run the validation. However, this may not be what you want, as you may want to check the validation output *before you even commit or release* your changes. This is where the second method comes in. This tests a project in the directory you are in, you can run:

```
$ git clone https://github.com/CLARIAH/tool-discovery/
$ export TOOL_DISCOVERY_PATH=$(pwd)/tool-discovery
$ docker pull proycon/codemeta-harvester
$ cd /path/to/your/project
$ docker run -v $(pwd):/data -v $TOOL_DISCOVERY_PATH:/tool-discovery proycon/codemeta-harvester --stdout --validate /tool-discovery/schemas/shacl/software.ttl
```


### Q: I think there's a bug in the harvester

**A:** Please report it on the [issue tracker](https://github.com/CLARIAH/tool-discovery/issues). Include your ``harvest.log`` and validation report if applicable.

### Q: There is an error in the metadata for a tool in your index, can you fix it?

**A:** Unless it's a bug on the harvester side: **no**, we can't do anything.
The maintainers of the tool themselves have full authorship over their metadata
and only they can change the metadata content for their tool. If you want to
help/contribute as a third party, contact the maintainer of the tool (or
preferably send them a pull/merge request on their repository to fix it
directly).
