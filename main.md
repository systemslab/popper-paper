---
title: "The Popper Convention: Treating Academic Papers as Open Source 
Software Projects"
author:
- name: "Ivo Jimenez, Michael Sevilla, Noah Watkins, Carlos Maltzahn"
  affiliation: "_UC Santa Cruz_"
  email: "`{ivo,msevilla,jayhawk,carlosm}@cs.ucsc.edu`"
number-of-authors: 1
abstract: |
 We make the case for treating an article as an open source software 
 project and for applying software engineering best-practices to 
 manage its associated artifacts and maintain the reproducibility of 
 its findings.
documentclass: ieeetran
classoption: conference
ieeetran: true
numbersections: true
substitute-hyperref: true
csl: "ieee.csl"
bibliography: "citations.bib"
usedefaultspacing: true
fontfamily: times
conferencename: VarSys2016
copyrightyear: 2016
keywords:
 - reproducibility
 - computer-systems
 - systems-validation
 - systems-evaluation
linkcolor: black
---

# Introduction

<!--
> We already have the tools; we need a convention.

A lot of related/existing work is reinventing the wheel. Creating 
"repos" for research stuff.
-->

Independent validation of experimental results in the field of 
computer systems research is a challenging task. Recreating an 
environment that resembles the one where an experiment was originally 
executed is a challenging endeavour. Even after achieving this, 
validating the outcome is a subjective task that requires 
domain-specific expertise in order to consider what differences 
between original and recreated environments might be the root cause of 
any discrepancies in the results.

A central issue in reproducibility is how to easily organize an 
article's experiments for readers or students. In this work, we 
revisit the idea of an executable paper, which poses the integration 
of executables and data with scholarly articles to help facilitate 
reproducibility. In our work we look at implementing it in today’s 
cloud-computing world by treating an article as an open source 
software project and apply software engineering best-practices to 
manage an article's associated artifacts and maintain the 
reproducibility of its findings. In particular, we leverage Git, 
Docker, Ansible and Jupyter notebooks, and use Github, Cloudlab and 
Binder as our proof-of-concept infrastructure. In this paper we 
describe in greater detail our convention. There are two main goals:

 1. It should apply to as many research projects as possible, 
    regardless of their domain.
 2. It should "work", regardless of the underlying technologies; if 
    not, there's a bug in the convention.

We take GassyFS [@watkins_gassyfs_2016] as a research project in which 
we apply this convention.

# Overview

Our approach:

  * An article has a Github repository associated with it, storing the 
    article text, experiments (along with input/output data), 
    Dockerfiles, and Ansible playbooks.
  * Every experiment has one or more Docker images associated with it, 
  * Every experiment has an Ansible playbook associated with it that 
    is used to setup and execute the experiment.
  * Experimental data is analyzed and visualized using Jupyter 
    notebooks. Every experiment has a notebook associated with it.
  * Every image in an article has a link in its caption that take the 
    reader to a Jupyter notebook that visualizes the experimental 
    results.

Given all the elements listed above, readers of a paper can look at a 
figure and click the associated link that takes them to a notebook. 
Then, if desired, they instantiate a Binder and can analyze the data 
further. After this, they might be interested in re-executing an 
experiment, which they can do by cloning the github repository and, if 
they have resources available to them (i.e. one or more docker hosts), 
they just point Ansible to them and re-execute the experiment locally 
in their environment. If resources are not available, an alternative 
is to launch a Cloudlab instance (one or more docker nodes hosted in 
Cloudlab) and point Ansible to the assigned IP addresses (we have 
performed some WRF-Docker tests this way). Another, even better 
alternative is to provide a way in which, after clicking a link, an 
experiment is prepared and configured in other clouds (EC2, GCE, 
Rackspace, etc). The user is taken to a web form that shows the 
parameters of the experiment, in case they want to change them, and 
provides a “Run” button to re-execute it. An open question is how do 
we deal with data that is too big to fit in Git. We’ve been recently 
working on a project (vio) that allows to store and reference large 
input/output datasets in a generic way (i.e. it works with many cloud 
providers like Git-lfs, Dropbox, Google Drive, etc.).

In the following, we use `git` as the VCS, `docker` as the experiment 
execution substrate, `ansible` as the orchestrator and the `scipy` 
stack for analysis/visualization. As stated in goal 2, any of these 
should be swappable for other tools, for example: VMs instead of 
docker; puppet instead of ansible; R insted of scipy; and so on and so 
forth.

## The tools

### Docker

Docker automates the deployment of applications inside software 
containers by providing an additional layer of abstraction and 
automation of operating-system-level virtualization on Linux.

### Ansible

Ansible is a configuration management utility for configuring and 
managing computers, as well as deploying and orchestrating multi-node 
applications.

### Jupyter

Jupyter notebooks are a web-based application allowing creation and 
sharing of documents containing live code (in Julia, Python or R), 
equations, visualizations and explanatory text.

## Infrastructure

### Cloudlab

Cloudlab is an NSF-sponsored infrastructure for research on cloud 
computing that allows users to easily provision bare-metal machines to 
execute multi-node experiments.

### Binder

Binder is an online service that allows one to turn a GitHub repo into 
a collection of interactive Jupyter notebooks so that readers don't 
need to deploy web servers themselves.

# Convention

## Organizing Files

The structure of a "paper repo" is the following:

```
paper/
  experiments/
    exp1/
      assertions.aver
      fig1.png
      inventory
      notebook.ipynb
      output.csv
      playbook.yml
      vars.yml
      run.sh
  build.sh
  main.md
```

We note the following:

  * A paper is written in any desired format. Here we use markdown as 
    an example (`main.md`).

  * There is a `build.sh` command that generates the output format 
    (e.g. `PDF`).

  * Every experiment in the paper has a corresponding folder in the 
    repo. For example, `exp1` referred in a paper, there is a 
    `experiments/exp1/` folder in the repo.

  * Every figure in the paper has a `[source]` link in its caption 
    that points to the URL of the corresponding experiment folder in 
    the web interface of the VCS (e.g. github).

  * `notebook.ipynb` contains the notebook that, at the very least, 
    displays the figures for the experiment. It can serve as an 
    "extended" version of what figures in the paper display, including 
    other figures that contain analysis that show similar results. If 
    the repo is checked out locally into another person's machine, 
    it's a nice way of having readers play with the result's data 
    (although they need to know how to instantiate a local notebook 
    server).

  * If desired, the experiment can be re-executed. The high-level data 
    flow is the following:

    ```
      edit(inventory) -> invoke(run.sh) ->
        ansible(pull_docker_images) ->
        ansible(run_docker_images) ->
        fetch(output, facts, etc) ->
        postprocess ->
        genarate_image ->
        aver_assertions
    ```

    Thus, the absolutely necessary files are `run.sh` which bootstraps 
    the experiment (by invoking a containerized ansible); `inventory`, 
    `playbook.yml` and `vars.yml` which are given to ansible.

    The execution of the experiment will produce output that is either 
    consumed by a postprocessing script, or directly by the notebook. 
    The output can be in any format (CSVs, HDF, NetCDF, etc.).

  * `output.csv` is the ultimate output of the experiment and what it 
    gets displayed in the notebook.

  * `playbook.yml`, `inventory`, `vars.yml`. Files for `ansible`. An 
    important component of the playbook is that it should `assert` the 
    environment and corroborate as much assumptions as possible (e.g. 
    via the `assert` task). `vars.yml` contains the parametrization of 
    the experiment.

  * `assertions.aver`. An optional file that contains assertions on 
    the output data in the _aver_ language.

## Organizing Dependencies

### Executables

For every execution element in the high-level script, there is a repo 
that has the source code of the executables, and an artifact repo that 
holds the output of the "pointed-to" version. In our example, we use 
git and docker. So, let's say the execution that resulted in `fig1` 
refers to code of a `foo` codebase. Then:

  * there's a git repo for `foo` and there's a tag/sha1 that we refer 
    to in the paper repo. This can optionally be also 
    referenced/tracked via git submodules (e.g. placed in the 
    `vendor/` folder).

  * for the version that we are pointing to, there is a docker image 
    in the docker hub. E.g. if foo#tag1 is what we refer to, then 
    there's a docker image <repo>/foo:tag1. We can optionally track 
    the image's source (dockerfile) with submodules.

### Datasets

Input/output files should be also versioned. For small datasets, we 
can can put them in the git repo (as in the example). For large 
datasets we can use `git-lfs`.

## Obtaining and Reporting Baseline Raw Performance

We have a toolkit that is composed of multiple docker images that 
measure CPU, memory, I/O and network raw performance of a deployment. 
We make this part of the results since this is our fingerprint of our 
systems. This also gives us an idea of the proportionality of the 
multiple subsystems (e.g. 10:1 of network to IO for example)

![GassyFS has facilities for explicitly managing  persistence to 
different storage targets. A checkpointing infrastructure gives 
GassyFS flexible policies for persisting namespaces and federating 
data.](figures/arch.png)

# GassyFS: a model project for Popper

GassyFS is a new prototype filesystem system that stores files in 
distributed remote memory and provides support for checkpointing file 
system state. The architecture of GassyFS is illustrated in Figure 2. 
The core of the file system is a user-space library that implements a 
POSIX file interface. File system metadata is managed locally in 
memory, and file data is distributed across a pool of network-attached 
RAM managed by worker nodes and accessible over RDMA or Ethernet. 
Applications access GassyFS through a standard FUSE mount, or may link 
directly to the library to avoid any overhead that FUSE may introduce.

By default all data in GassyFS is non-persistent. That is, all 
metadata and file data is kept in memory, and any node failure will 
result in data loss. In this mode GassyFS can be thought of as a 
high-volume tmpfs that can be instantiated and destroyed as needed, or 
kept mounted and used by applications with multiple stages of 
execution. The differences between GassyFS and tmpfs become apparent 
when we consider how users deal with durability concerns.

At the bottom of Figure 2 are shown a set of storage targets that can 
be used for managing persistent checkpoints of GassyFS. **TODO**: talk 
about volatility. Finally, GassyFS supports a form of file system 
federation that allows checkpoint content to be accessed remotely to 
enable efficient data sharing between users over a wide-area network. 

In subsequent sections we describe several experiments and detail how 
we obtained the baselines. The key in reproducibility is to reproduce 
the baselines!

## Experiment 1: GassyFS vs. TempFS

## Experiment 2: Scalability

## Experiment 3: UDP vs. Infiniband Performance

## Experiment 4: Analytics on GassyFS

# Discussion

> **NOTE**: these subsections might merge with others or turn into 
sections of their own.

## More Analogies

Take a look to a project and break it down into its components w.r.t. 
the development parts (code, tests, artifacts, 3rd party libs).

  * code: the latex file
  * artifacts: figures, input/output data
  * 3rd party libraries: code from us that we've developed for the 
    article or stuff we make use of
  * tests:
      * unit tests: check that PDF/figures are generated correctly
      * integration tests: experiments are runnable, e.g. all the 
        dependencies
      * regression tests: we ensure that the claims made in the paper 
        are valid, e.g. after a change on the associated code base or 
        by adding a new "supported platform"

A CI tool needs to be available, e.g. if we have Travis or Jenkins 
then we can make sure that we don't "break" the paper. For example in 
CloudLab, we might have multiple experiments that might be broken 
after a new site gets upgraded.

## Numerical vs. Performance Reproducibility

In many areas of computer systems research, the main subject of study 
is performance, a property of a system that is highly dependant on 
changes and differences in software and hardware in computational 
environments. Performance reproducibility can be contrasted with 
numerical reproducibility. Numerical reproducibility deals with 
obtaining the same numerical values from every run, with the same code 
and input, on distinct platforms. For example, the result of the same 
simulation on two distinct CPU architectures should yield the same 
numerical values. Performance reproducibility deals with the issue of 
obtaining the same performance (run time, throughput, latency, etc.) 
across executions. We set up an experiment on a particular machine and 
compare two algorithms or systems.

We can compare two systems with either controlled or statistical 
methods. In controlled experiments, the computational environment is 
controlled in such a way that the executions are deterministic, and 
all the factors that influence performance can be quantified. The 
statistical approach starts by first executing both systems on a 
number of distinct environments (distinct computers, OS, networks, 
etc.). Then, after taking a significant number of samples, the claims 
of the behavior of each system are formed in statistical terms, e.g. 
with 95\% confidence one system is 10x better than the other. The 
statistical reproducibility method is gaining popularity, e.g. 
[@hoefler_scientific_2015].

Current practices in the Systems Research community don't include 
either controlled or statistical reproducibility experiments. Instead, 
people run several executions (usually 10) on the same machine and 
report averages. Our research focuses in looking at the challenges of 
providing controlled environments by leveraging OS-level 
virtualization. [@jimenez_characterizing_2016] reports some 
preliminary work.

Our convention can be used to either of these two approaches.

# Related Work

In [@dolfi_model_2014], the authors introduce a "paper model" of 
reproducible research which consists of an MPI application used to 
illustrate how to organize a project. We extend this idea by having 
our convention be centered on version control systems and include the 
notion of instant replicability by using docker and ansible.


**TODO**:

  * ReproZip
  * A collaborative approach to computational reproducibility
  * open science framework (OSF)
  * open science
  * similar but limited to just generating the PDF: [how we make our 
    papers 
    replicable](http://ivory.idyll.org/blog/2014-our-paper-process.html)
  * should we reference [@jimenez_characterizing_2016]?

# Bibliography

<!-- hanged biblio -->

\noindent
\vspace{-2em}
\setlength{\parindent}{-0.2in}
\setlength{\leftskip}{0.2in}
\setlength{\parskip}{8pt}
