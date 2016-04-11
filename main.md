---
title: "Popper: Making Reproducible Systems Performance Evaluation 
Practical"
author:
- name: '  '
  affiliation: ' '
  email: '  '
#- name: "Ivo Jimenez, Michael Sevilla, Noah Watkins, Carlos Maltzahn"
  #affiliation: "_UC Santa Cruz_"
  #email: "`{ivo,msevilla,jayhawk,carlosm}@cs.ucsc.edu`"
number-of-authors: 4
abstract: |
  Independent validation of experimental results in the field of 
  parallel and distributed systems research is a challenging task, 
  mainly due to changes and differences in software and hardware in 
  computational environments. Recreating an environment that resembles 
  the original systems research is difficult and time-consuming. In this paper we 
  introduce the _Popper Convention_, a set of principles for producing 
  useful research and scientific publications that are easy to validate. Concretely, we make 
  the case for treating an article as an open source software (OSS) 
  project and for applying software engineering best-practices to 
  manage its associated artifacts and maintain the reproducibility of 
  its findings. We propose leveraging existing cloud-computing 
  infrastructure and modern OSS development tools to produce academic 
  articles that are easy to validate. We present our prototype file 
  system, GassyFS, as a use case for illustrating the usefulness of 
  this approach. We show how, by following Popper, re-executing 
  experiments on multiple platforms is more practical,
  allowing reviewers and students to quickly get to the point of 
  getting results without relying on the author's intervention.
documentclass: ieeetran
classoption: conference
ieeetran: true
numbersections: true
substitute-hyperref: true
csl: "ieee.csl"
bibliography: "citations.bib"
usedefaultspacing: true
links-as-notes: true
fontfamily: times
conferencename: SC2016
copyrightyear: 2016
keywords:
 - reproducibility
 - computer-systems
 - systems-validation
 - systems-evaluation
linkcolor: black
---

# Introduction

A key component of the scientific method is the ability to revisit and 
replicate previous experiments. Managing information about an 
experiment allows scientists to interpret and understand results, as 
well as verify that the experiment was performed according to 
acceptable procedures. Additionally, reproducibility plays a major 
role in education since the amount of information that a student has 
to digest increases as the pace of scientific discovery accelerates. 
By having the ability to repeat experiments, a student learns by 
looking at provenance information about the experiment, which allows 
them to re-evaluate the questions that the original experiment 
addressed. Instead of wasting time managing package conflicts
and learning the paper author's ad-hoc experimental setups, the 
student can immediately run the original experiments and build on the 
results in the paper, thus allowing them to "stand on the shoulder of 
giants".

![The OSS development model. A version-control system is used to 
maintain the changes to code. The software is packaged and those 
packages are used in either testing or deployment. The testing 
environment ensures that the software behaves as expected. When the 
software is deployed in production, or when in needs to be checked for 
performance integrity, it is monitored and metrics are analyzed in 
order to determine any problems.](figures/ossmodel.png)

Independently validating experimental results in the field of computer 
systems research is a challenging task. Recreating an environment that 
resembles the one where an experiment was originally executed is a 
challenging endeavour. Version-control systems give authors,
reviewers and readers access to the same code base 
[@brown_how_2014] but the availability of source code does not 
guarantee reproducibility [@collberg_repeatability_2015]; code may not
compile, and even it does, the results may 
differ. In this case, validating the outcome is a subjective task that 
requires domain-specific expertise in order to determine the 
differences between original and recreated environments that might be 
the root cause of any discrepancies in the results 
[@jimenez_tackling_2015-1 ; @freire_computational_2012 ; 
@donoho_reproducible_2009]. Additionally, reproducing experimental 
results when the underlying hardware environment changes is 
challenging mainly due to the inability to predict the effects of such 
changes in the outcome of an experiment [@saavedra-barrera_cpu_1992 ; 
@woo_splash2_1995]. A Virtual Machine (VM) can be used to partially 
address this issue but the overheads in terms of performance (the 
hypervisor "tax") and management (creating, storing and transferring) 
can be high and, in some fields of computer science such as systems 
research, cannot be accounted for easily [@clark_xen_2004 ; 
@klimeck_nanohuborg_2008]. OS-level virtualization can help in 
mitigating the performance penalties associated with VMs 
[@jimenez_role_2015].

One central issue in reproducibility is how to organize an article's 
experiments so that readers or students can easily repeat them. The 
current practice is to make the code available in a public repository 
and leave readers with the daunting task of recompiling, 
reconfiguring, deploying and re-executing an experiment. In this work, 
we revisit the idea of an executable paper 
[@strijkers_executable_2011], which poses the integration of 
executables and data with scholarly articles to help facilitate its 
reproducibility, but look at implementing it in today's 
cloud-computing world by treating an article as an open source 
software (OSS) project. We introduce _Popper_, a convention for 
organizing an article's artifacts following the OSS development model 
that allows researchers to make all the associated artifacts publicly 
available with the goal of easing the re-execution of experiments and 
validation of results. There are two main goals for this convention:

 1. It should apply to as many research projects as possible, 
    regardless of their domain. While the use case shown in _Section 
    IV_ pertains to the area of distributed storage systems, our goal 
    is to embody any project with a computational component in it.
 2. It should be applicable, regardless of the underlying 
    technologies. In general, Popper relies on software-engineering 
    practices like continuous integration (CI) which are implemented 
    in multiple existing tools. Applying this convention should work, 
    for example, regardless of what CI tool is being used.

If, from an article's inception, researchers make use of 
version-control systems, lightweight OS-level virtualization, 
automated multi-node orchestration, continuous integration and 
web-based data visualization, re-executing and validating an 
experiment becomes practical. This paper makes the following 
contributions:

  * An analysis of how the OSS development process can be repurposed 
    to an academic article;
  * Popper: a convention for writing academic articles and associated 
    experiments following the OSS model; and
  * GasssyFS: a scalable in-memory file system that adheres to the 
    Popper convention.

Our use case highlights the ability of re-executing experiments on 
multiple platforms with minimal effort, and how automated performance 
regression testing helps in maintaining the reproducibility integrity 
of experiments.

The rest of the paper is organized as follows. _Section II_ analyzes 
the traditional OSS development model and how it applies to academic 
articles. _Section III_ describes _Popper_ in detail and gives an 
overview of the high-level workflow that a researcher goes through 
when writing an article following the convention. In _Section IV_ we 
present a use case of a project following Popper. We discuss some of 
the limitations of Popper and lessons learned in _Section V_. Lastly, 
we review related work on _Section VI_ and conclude.

<!--
# Reproducibility Needs More than Source Code

Software projects use sophisticated tools to ensure the integrity of 
their source code. Collaborating, sharing, and maintaining a history
of code is easy. Unfortunately, running the code in new environments
is difficult because the source code does not include sufficient 
details about the developer's software environment, hardware, workload 
paramaters, and experimental/benchmarking setup(s).

This innefficiencies make reproducibility difficult and even the 
most diligent developer must make trade-offs in how they report 
their methodologies. Over documentation can be overwhelming for 
new users while insufficient documentation makes it impossible
for anyone to reproduce results. Furthermore, these ad-hoc 
methologies make it difficult to adapt to new software projects
and communities -- what is needed is a standard for packaging, 
deploying, and monitoring your system.

## Software Enviroment

- packages, distros, compilers, deployment, tunables

The software environment is the software the surrounds the source code. It
includes the binaries on the host system (packages, distros, compilers) and 
pre-flight setup. Obviously, there are many ways of deploying these systems.
For example, for the experiments in this paper, we use GASNet. For our
version of GASNet, there are 64 flags for additional packages and 138 
flags for additional features. We use:
```
./configure \
  --prefix=/usr \
  --enable-udp \
  --enable-ibv \
  --disable-mpi \
  --enable-par \
  --enable-segment-everything \
  --disable-aligned-segments \
  --disable-pshm \
  --with-segment-mmap-max=160GB
```

To mount GassyFS, we use FUSE. In addition to the 3 flags we add for our 
file system, there are about 30 options for mounting FUSE. We use:

```
/usr/local/bin/amudprun -np 2 /gassy mount 
  -o allow_other -o fsname=gassy -o atomic_o_trunc -o rank0_alloc
```

Although GassyFS is a simple system, the code snippets above illustrate
the complexity of deploying, tuning, and configuring it. Furthermore, it is
unreasonable to ask the developer to list and test every enviroments packages, 
distros, and compilers. Merely listing these in a notebook or email is 
insufficient for sharing, colloborating, and distributing experimentl results
and the methodology for sharing these environments is specific to each developer

## Hardware

- specifications (network speed, processor architectures, storage media),
cluster configuration, system integrity (slow disk, overloaded network, etc.)

Example: GassyFS runs in infiniband which takes tuning and file handle limits


## Workload Paramters

- talk about hadoop mappers/reducers and auxiliary systems that are used.

## Experimental/Benchmarking Setup(s)

- talk about running the jobs (e.g., what kind of `dd` tests we do)

Stuff that makes reproducibility harder:

## Requirements of Writing Reproducible Papers 

Systems are much more complicated than source code and each component
of an experimental setup should be treated with the same care that 
give software. In this work, we take the ultimate achievement in 
science, a published academic paper, and use software tools to ensure 
that others cans run the same experiments and draw the same, and 
hopefully new, conclusions. We argue that existing software tools, 
when combined correctly, provide all the technology necessary for 
reproducing experiments.

Writing scientific papers is amenable to OSS methologies because both 
processes require:

1. maintaining a history of work

2. sharing and collaborating

3. testing and verification

-->

# The OSS Development Model for Academic Articles

In the following section, we look at software tools for maintaining 
code and describe how they can help make scientific papers reproducible.
By using these tools for maintaining experiments in the paper, the authors
enjoy the same benefits that the tools provide for software. We use the 
generic OSS workflow in Figure 1 to guide our discussion.

## Version Control

Traditionally the content managed in a version-control system (VCS) is 
the project's source code; for an academic article the equivalent is 
the article's content: article text, experiments (code and data) and 
figures. The idea of keeping an article's source in a VCS is not new 
and in fact many people follow this practice [@brown_how_2014 ; 
@dolfi_model_2014]. However, this only considers automating the 
generation of the article in its final format (usually PDF). While this 
is useful, here we make the distinction between changing the prose of the paper 
and changing the parameters of the experiment (both its components and 
its configuration).

Ideally,
one would like to version-control the entire end-to-end pipeline for 
all the experiments contained in an article. With the advent of 
cloud-computing, this is possible for most research 
articles[^difficult-platforms]. One of the mantras of the DevOps 
movement [@wiggins_twelvefactor_2011] is to make "infrastructure as 
code". In a sense, having all the article's dependencies in the same 
repository is analogous to how large cloud companies maintain 
monolithic repositories to manage their internal infrastructure 
[@tang_holistic_2015 ; @metz_google_2015] but at a lower scale.

[^difficult-platforms]: For large-scale experiments or those that run 
on specialized platforms, re-executing an experiment might be 
difficult. However, this doesn't exclude such research projects from 
being able to version-control the article's associated assets.

<!--
To illustrate the usefulness of a VCS to manage an article's 
dependencies, consider an article's experiments and how they evolve 
throughout the life-cycle of an article. Figure 2 shows a timeline...

**TODO**: Add diagram of a timeline with results being affected by 
changes in the.
-->

**Tools and services**: git, svn and mercurial are popular VCS tools. 
GitHub and BitBucket are web-based Git repository hosting services. 
They offer all of the distributed revision control and source code 
management (SCM) functionality of Git as well as adding their own 
features. They give new users the ability to look at the entire 
history of the authors' development process.

## Package Management

Availability of code does not guarantee reproducibility of results 
[@collberg_repeatability_2015]. The second main component on the OSS 
development model is the packaging of applications so that users don't 
have to. Software containers (e.g. Docker, OpenVZ or FreeBSD's jails) 
complement package managers by packaging all the dependencies of an 
application in an entire filesystem snapshot that can be deployed in 
systems "as is" without having to worry about problems such as package 
dependencies or specific OS versions. From the point of view of an 
academic article, these tools can be leveraged to package the 
dependencies of an experiment. Software containers like Docker have 
the great potential for being of great use in computational sciences 
[@boettiger_introduction_2014].

**Tools and services**: Docker [@merkel_docker_2014] automates the 
deployment of applications inside software containers by providing an 
additional layer of abstraction and automation of 
operating-system-level virtualization on Linux. Alternatives to docker 
are modern package managers such as Nix [@dolstra_nixos_2008] or Spack 
[@gamblin_spack_2015], or even virtual machines.

## Continuous Integration

Continuous Integration (CI) is a development practice that requires 
developers to integrate code into a shared repository frequently with 
the purpose of catching errors as early as possible. An experiment is 
not absent of this type of issues. If an experiment's findings can be 
codified in the form of a unit test, this can be verified on every 
change to the article's repository.

**Tools and services**: Travis CI is an open-source, hosted, 
distributed continuous integration service used to build and test 
software projects hosted at GitHub. Alternatives to Travis CI are 
CircleCI, CodeShip. Other on-premises solutions exist such as Jenkins.

## Multi-node Orchestration

Experiments that require a cluster need a tool that automatically 
manages binaries and updates packages across machines. Serializing this
by having an administrator manage all the nodes in a cluser is 
impossible in HPC settings. Traditionally, this is done with an ad-hoc
bash script but for experiments that are continually tested there needs
to be an automated solution.

**Tools and services**: Ansible is a configuration management utility 
for configuring and managing computers, as well as deploying and 
orchestrating multi-node applications. Similar tools include Puppet, 
Chef, Salt, among others.

## Bare-metal-as-a-Service

For experiments that cannot run on consolidated infrastructures due to 
noisy-neighborhood phenomena, bare-metal as a service is an 
alternative.

**Tools and services**: Cloudlab [@ricci_introducing_2014], Chameleon 
and PRObE [@gibson_probe_2013] are NSF-sponsored infrastructures for 
research on cloud computing that allows users to easily provision 
bare-metal machines to execute multi-node experiments. Some cloud 
service providers such as Amazon allow users to deploy applications on 
bare-metal instances.

## Automated Performance Regression Testing

OSS projects such as the Linux kernel go through rigorous performance 
testing [@intel_linux_2016] to ensure that newer version don't 
introduce any problems. Performance regression testing is usually an 
ad-hoc activity but can be automated using high-level languages or 
[@jimenez_aver_2016] or statistical techniques 
[@nguyen_automated_2012]. Another important aspect of performance 
testing is making sure that baselines are reproducible, since if they 
are not, then there is no point in re-executing an experiment.

**Tools and services**: Aver is language and tool that allows authors 
to express and validate statements on top of metrics gathered at 
runtime. For obtaining baselines Baseliner is a tool that can be used 
for this purpose.

## Data Visualization

Once an experiment runs, the next task is to analyze and visualize 
results. This is a task that is usually not done in OSS projects. 

**Tools and services**: Jupyter notebooks run on a web-based 
application. It facilitates the sharing of documents containing live 
code (in Julia, Python or R), equations, visualizations and 
explanatory text. Other domain-specific visualization tools can also 
fit into this category. [Binder](mybinder.org) is an online service 
that allows one to turn a GitHub repository into a collection of 
interactive Jupyter notebooks so that readers don't need to deploy web 
servers themselves.

# The Popper Convention

![End-to-end workflow for an article that follows the Popper 
convention.](figures/wflow.png)

_Popper_ is a convention for articles that are developed as an OSS 
project. In the remaining of this paper we use GitHub, Docker, Binder, 
CloudLab, Travis CI and Aver as the tools/services for every component 
described in the previous section. As stated in goal 2, any of these 
should be swappable for other tools, for example: VMs instead of 
Docker; Puppet instead of Ansible; Jenkins instead of Travis CI; and 
so on and so forth. Our approach can be summarized as follows:

  * Github repository stores all details for the paper. It stores the 
    metadata necessary to build the paper and re-run experiments. 
  * Docker images capture the experimental environment, packages and tunables.
  * Ansible playbook deploy and execute the experiments.
  * Travis tests the integrity of all experiments.
  * Jupyter notebooks analyze and visualize experimental data produced 
    by the authors.
  * Every image in an article has a link in its caption that takes the 
    reader to a Jupyter notebook that visualizes the experimental 
    results.
  * Every experiment involving performance metrics can be launched in 
    CloudLab, Chameleon or PRObE.
  * The reproducibility of every experiment can be checked by running 
    assertions of the aver language on top of the newly obtained 
    results.

Figure 2 shows the end-to-end workflow for reviewers and authors. 
Given all the elements listed above, readers of a paper can look at a 
figure and click the associated link that takes them to a notebook. 
Then, if desired, they instantiate a Binder and can analyze the data 
further. After this, they might be interested in re-executing an 
experiment, which they can do by cloning the github repository and, if 
they have resources available to them (i.e. one or more docker hosts), 
they just point Ansible to them and re-execute the experiment locally 
in their environment. If resources are not available, an alternative 
is to launch a Cloudlab, Chameleon or PRObE instance (one or more 
docker nodes hosted in Cloudlab) and point Ansible to the assigned IP 
addresses. An open question is how do we deal with datasets that are 
too big to fit in Git. An alternative is to use `git-lfs` to version 
and store large datasets.

## Organizing Files

The structure of an example "paper repo" is shown in Figure 3. A paper 
is written in any desired format. Here we use markdown as an example 
(`main.md` file). There is a `build.sh` command that generates the 
output format (e.g. `PDF`). Every experiment in the paper has a 
corresponding folder in the repo. For example, for a `scalability` 
experiment referred in the paper, there is a 
`experiments/scalability/` folder in the repository.

Inside each experiment folder there is a Jupyter notebook that, at the 
very least, displays the figures for the experiment that appear in the 
paper. It can serve as an extended version of what figures in the 
paper display, including other figures that contain analysis that show 
similar results. If readers wants to do more analysis on the results 
data, they can instantiate a Binder by pointing to the github 
repository. Alternatively, If the repository is checked out locally 
into another person's machine, it's a nice way of having readers play 
with the result's data (although they need to know how to instantiate 
a local notebook server). Every figure in the paper has a `[source]` 
link in its caption that points to the URL of the corresponding 
notebook in GitHub[^github-ipy].

[^github-ipy]: GitHub has the ability to render jupyter notebooks on 
its web interface. This is a static view of the notebook (as produced 
by the original author). In order to have a live version of the 
notebook, one has to instantiate a Binder or run a local notebook 
server.

For every experiment, there is an ansible playbook that can be used to 
re-execute the experiment. In order to do so, readers clone the 
repository, edit the `inventory` file by adding the IP addresses or 
hostnames of the machines they have available. The absolutely 
necessary files for an experiment are `run.sh` which bootstraps the 
experiment (by invoking a containerized ansible); `inventory`, 
`playbook.yml` and `vars.yml` which are given to ansible. The 
execution of the experiment will produce output that is either 
consumed by a postprocessing script, or directly by the notebook. The 
output can be in any format (CSVs, HDF, NetCDF, etc.). `output.csv` is 
the ultimate output of the experiment and what it gets displayed in 
the notebook. An important component of the experiment playbook is 
that it should assert the environment and corroborate as much as 
possible the assumptions made by the original (e.g. via the `assert` 
task, check that the Linux kernel is the required one). `vars.yml` 
contains the parametrization of the experiment.

At the root of the project, there is a `.travis.yml` file that Travis 
CI uses to run unit tests on every commit of the repository. For 
example, if an experiment playbook is changed, say, by adding a new 
variable, Travis will ensure that, at the very least, the experiments 
can be launched without any issues.

Aver can be used for checking that the original findings of an 
experiment are valid for new re-executions. An `assertions.aver` file 
contains assertions in the Aver language. This file is is given to 
Aver's assertion checking engine, which also takes as input the files 
corresponding to the output of the experiment. Aver then checks that 
the given assertions hold on the given performance metrics. This 
allows to automatically check that high-level statements about the 
outcome of an experiment are true.

![Structure of a folder for a project following the Popper convention. 
The red markers correpond to dependencies for the generation of the 
PDF, while the blue ones mark files used for the 
experiment.](figures/experiment-metadata.png)

**TODO (improve wording)**: When validating performance, an important 
component is to see the baseline performance of the experimental 
environment we are running on. Ansible has a way of obtaining "facts" 
about machines that is useful to have when validating results. Also, 
baseliner profiles that are associated to experimental results are a 
great way of asserting assumptions about the environment. baseliner is 
composed of multiple docker images that measure CPU, memory, I/O and 
network raw performance of a set of nodes. We execute baseliner on 
multi-node setups and make the profiles part of the results since this 
is the fingerprint of our execution. This also gives us an idea of the 
relationship among the multiple subsystems (e.g. 10:1 of network to 
IO).

## Organizing Dependencies

A paper repo is mainly composed of the article text and experiment 
orchestration logic. The actual code that gets executed by an 
experiment is not part of the paper repository. Similarly for any 
datasets that are used as input to an experiment. These dependencies 
should reside in their own repositories and be referenced in an 
experiment playbook.

### Executables

For every execution element in the experiment playbook, there is a 
repository that has the source code of the executables, and an 
artifact repository (package manager or software image repository) 
that holds the executables for referenced versions. In our example, we 
use git and docker. Assume the execution of an scalability experiment 
refers to code of a `mysystem` codebase. Then:

  * there's a git repo for `mysystem` that holds its source code and 
    there's a tag/sha1 that we refer to in our experiment. This can 
    optionally be also tracked via git submodules (e.g. placed in a 
    `vendor/` folder).

  * for the version that we are pointing to, there is a docker image 
    in the docker hub. For example, if we reference version `v3.0.3` 
    of `mysystem` in our experiment, then there's a docker image 
    `mysystem#v3.0.3` in the docker hub repository. We can also 
    optionally track the docker image's source (the `Dockerfile`) with 
    git submodules in the paper repository (`vendor/` folder).

### Datasets

Input/output files should be also versioned. For small datasets, we 
can can put them in the git repository of the paper. For large 
datasets we can use `git-lfs`.

# GassyFS: a model project for Popper

GassyFS [@watkins_gassyfs_2016] is a new prototype filesystem system 
that stores files in distributed remote memory and provides support 
for checkpointing file system state. The architecture of GassyFS is 
illustrated in Figure 4. The core of the file system is a user-space 
library that implements a POSIX file interface. File system metadata 
is managed locally in memory, and file data is distributed across a 
pool of network-attached RAM managed by worker nodes and accessible 
over RDMA or Ethernet. Applications access GassyFS through a standard 
FUSE mount, or may link directly to the library to avoid any overhead 
that FUSE may introduce.

By default all data in GassyFS is non-persistent. That is, all 
metadata and file data is kept in memory, and any node failure will 
result in data loss. In this mode GassyFS can be thought of as a 
high-volume tmpfs that can be instantiated and destroyed as needed, or 
kept mounted and used by applications with multiple stages of 
execution. The differences between GassyFS and tmpfs become apparent 
when we consider how users deal with durability concerns.

At the bottom of Figure 4 are shown a set of storage targets that can 
be used for managing persistent checkpoints of GassyFS. Given the 
volatility of memory, durability and consistency are handled 
explicitly by selectively copying data across file system boundaries. 
Finally, GassyFS supports a form of file system federation that allows 
checkpoint content to be accessed remotely to enable efficient data 
sharing between users over a wide-area network.

In subsequent sections we describe several experiments that evaluate 
the performance of GassyFS. We note that while the performance numbers 
obtained are relevant, they are not our main focus. Instead, we put 
more emphasis on how we obtained the baselines for our experiments, 
how we organize them in the paper repository and how we can reproduce 
results on multiple environments with minimal effort.

## Experimental Setup

We have two sets of machines. The first two experiments use machines 
in Table 1. The third experiment uses machines in Table 2. While our 
experiments should run on any Linux kernel that is supported by Docker 
(3.2+), we ran on kernels 3.19 and 4.2. Version 3.13 on Ubuntu has a 
known bug that impedes docker containers to launch sshd daemons, thus 
our experiments don't run on this version. Besides this, the only 
requirement is to have the Docker engine version 1.10 (or newer).

![GassyFS has facilities for explicitly managing  persistence to 
different storage targets. A checkpointing infrastructure gives 
GassyFS flexible policies for persisting namespaces and federating 
data.](figures/arch.pdf)

\begin{table}[ht]
\caption{Machines used in Experiments 1 and 2.}

\scriptsize
\centering
\begin{tabular}{@{} c c c c @{}}
\toprule

Machine ID & CPU Model              & Memory BW & Release Date \\\midrule
$M_1$         & Core i7-930 @2.8GHz    & 6x2GB DDR3   & Q1-2010 \\
$M_2$         & Xeon E5-2630 @2.3GHz   & 8x8GB DDR3   & Q1-2012 \\
$M_3$         & Opteron 6320 @2.8GHz   & 8x8GB DDR3   & Q3-2012 \\
$M_4$         & Xeon E5-2660v2 @2.2GHz & 16x16GB DDR4 & Q3-2013 \\

\end{tabular}
\end{table}


\begin{table}[ht]
\caption{Machines used in Experiment 3.}

\scriptsize
\centering
\begin{tabular}{@{} c c c c @{}}
\toprule

Machine ID & CPU Model              & Memory BW & Release Date \\\midrule
cloudlab   & Xeon E5-310 @1.6GHz   & 4x2GB DDR2   & Q4-2006 \\
ec2        & Core i7-930 @2.8GHz    & 6x2GB DDR3   & Q1-2010 \\
ec2-net    & Core i5-2400 @3.1GHz   & 2x4GB DDR3   & Q1-2011 \\
ucsc       & Core i5-2400 @3.1GHz   & 2x4GB DDR3   & Q1-2011 \\

r3.4xlarge  16 vCPU 122 GB RAM  1 x 320
High Frequency Intel Xeon E5-2670 v2

\end{tabular}
\end{table}

For every experiment, we first describe the goal of the experiment and 
show the result. Then we describe how we codify our observations in 
the Aver language. Before every experiment executes, Baseliner obtains 
baseline metrics for every machine in the experiment. At the end, Aver 
asserts that the given statements hold true on the metrics gathered at 
runtime. This helps to automatically check when experiments are not 
generating expected results

## Experiment 1: GassyFS vs. TempFS

The goal of this experiment is to compare the performance of GassyFS 
with respect to that of TempFS on a single node. As mentioned before, 
the idea of GassyFS is to serve as a distributed version of TmpFS.
Figure 3 shows the results of this test. We can see that GassyFS, due 
to the FUSE overhead, performs within 90% of TmpFS's performance. The 
validation statements for this experiments are the following:

```
when
  workload=*
expect
  time(fs=gassyfs) > 0.8 * time(fs=tmpfs)
```

![GassyFS vs tmpfs variability.](figures/gassyfs-variability.png)

## Experiment 2: Analytics on GassyFS

One of the main use cases of GassyFS is for data analytics workloads. 
By providing larger amounts of memory, an analysis application can 
crunch more numbers and thus generate more accurate results. The goal 
of this experiment is to compare the performance of Dask when it runs 
on GassyFS vs. on the local filesystem. Dask is a python library for 
parallel computing analytics that extends NumPy to out-of-core 
datasets by blocking arrays into small chunks and executing on those 
chunks in parallel. This allows python to easily process large data 
and also simultaneously make use of all of our CPU resources. Dask 
assumes that an n-dimensional array won't fit in memory and thus 
chunks the datasets (on disk) and iteratively process them in-memory. 
While this works fine for single-node scenarios, an alternative is to 
load a large array into GassyFS, and then let Dask take advantage of 
the larger memory size.

In this experiment, we show. The following assertion is used to test 
the integrity of this result.

```
when
  fs=gassyfs
expect
  time(analytic_routines = 1) < time(analytic_routines > 1)
when
  analytic_routines=*
expect
  time(fs=gassyfs) > time(fs=local)
```

The first condition asserts that, the first time that GassyFS runs an 
analytic routine in Dask, it has to pay the upfront cost of copying 
files into GassyFS. The second statement expresses that, regardless of 
the number of analytic routines, it is always faster to execute Dask 
on GassyFS than on the local filesystem.

![Dask workload on GassyFS.](figures/dask.png)

## Experiment 3: Scalability

One of the use cases of tmpfs is in the analysis of data. When data is 
too big to fit in memory, alternatives resort to either scale-out or 
do.

The corresponding experiment folder in the paper repository contains 
the necessary ansible files to re-execute this experiment with minimum 
effort. The only assumption is docker +1.10 and root access on the 
remote machine where this runs. The validation statements for this 
experiments are the following:

```
for
  workload=*
expect
  time(fs=gassyfs) > 0.8 * time(fs=tmpfs)
```

![Dask workload on GassyFS.](figures/dask.png)

# Discussion

## Convention over Technology

The value of docker is not the technology but that helps people agree 
on a complex issue. One could argue the same about Ansible, but for 
"distributed bash" (many people has tried to done this in the past 
unsuccessfully but Ansible is being adopted everywhere).

We want to have the same effect in the academic realm. By having 
docker/ansible as a lingua franca for researches, and Popper to guide 
them in how to structure their paper repos, we can expedite 
collaboration and at the same time benefit from all the new advances 
done in the cloud-computing/DevOps world.

## Something will always break

No matter how hard we try, there will always be something that goes 
wrong. We don't aim at perfect repeatability but to minimize the 
issues we face and (see above) have a common language that can be used 
while collaborating to fix all these reproducibility issues.

## Drawing the line between deploy and packaging

Figuring out where something should be in the deploy framework (e.g., 
Ansible) or in the package framework (e.g., Docker) must be 
standardized by the users of the project. One could implement Popper 
entirely with Ansible but this introduces complicated playbooks and 
permantently installs packages on the host. Alternatively, one could 
use Docker to orchestrate services but this requires "chaining" images 
together. This process is hard to develop since containers must be 
recompiled and shared around the cluster.

## Usability is the key to make this work

There are some entry-level barriers for this to work.

### Things that piss people off

  * Not everybody knows git
  - number files in the paper rpo
  - lines of code in the paper repo
  - number of submodules

### Containers are not Virtualization

People usually misunderstand how OS-level virtualization works.

  - no performance hit
  - no network port remapping
  - no layers of indirection

### Containers are not baremetal

First encounters with docker require a paradigm shift. Docker is 
immutable infrastructure.

  * need to login as if it were a regular linux server
  - can't ssh into them to start services (which is how most services 
    start daemons)
  - need to have a service per image
  * container state must be immutable: you can't sudo apt-get install 
    stuff into them and expect those packages to be installed after 
    you relaunch the container

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

## New Categories For Experimental Evaluations

We envision two new categories for reporting performance results in 
academic articles: controlled experiments vs. statistical studies. Our 
work fits on the former, where a great amount of effort is devoted to 
ensure that all the relevant factors that influence performance are 
carefully accounted for. However, this does not correspond to 
real-world scenarios thus, in the latter, applications run without 
constraints so that they can take advantage of all the resources 
available to them but sound statistical analysis 
[@hoefler_scientific_2015] is applied to the experimental design and 
analysis of results.

## Providing Performance Profiles Alongside Experimental Results

This allows to preserve the performance characteristics of the 
underlying hardware that an experiment executed on and facilitates the 
interpretation of results in the future.

## Handling of results

We might need to find another way of managing experimental results. 
Putting results on git won't scale. There's also the issue of naming 
and experiment metadata.

# Related Work

The challenging task of evaluating experimental results in applied 
computer science has been long recognized [@ignizio_establishment_1971 
; @ignizio_validating_1973 ; @crowder_reporting_1979]. This issue has 
recently received a significant amount of attention from the 
computational research community [@freire_computational_2012 ; 
@neylon_changing_2012 ; @leveqije_reproducible_2012 ; 
@stodden_implementing_2014], where the focus is more on numerical 
reproducibility rather than performance evaluation. Similarly, efforts 
such as _The Recomputation Manifesto_ [@gent_recomputation_2013] and 
the _Software Sustainability Institute_ [@crouch_software_2013] have 
reproducibility as a central part of their endeavour but leave runtime 
performance as a secondary problem. In systems research, runtime 
performance _is_ the subject of study, thus we need to look at it as a 
primary issue. By obtaining profiles of executions and making them 
part of the results, we allow researchers to validate experiments with 
performance in mind.

Recent efforts have looked at creating open science portals or 
repositories [@bhardwaj_datahub_2014 ; @king_introduction_2007 ; 
@stodden_researchcompendiaorg_2015 ; @centerforopenscience_open_2014] 
that hold all (or a subset of) the artifacts associated to an article. 
In our case, by treating an article as an OSS project, we benefit from 
existing tools and web services such as git-lfs without having to 
implement domain-specific tools. In the same realm, some services 
provide researchers with the option of generating and absorving the 
cost of a digital object identifier (DOI). Github projects can have a 
DOI associated with it [@smith_improving_2014], which is one of the 
main reasons we use it as our VCS service.

A related issue is the publication model. In 
[@chirigati_collaborative_2016] the authors propose to incentivize the 
reproduction of published results by adding reviewers as co-authors of 
a subsequent publication. We see the Popper convention as a 
complementary effort that can be used to make the facilitate the work 
of the reviewers.

The issue of structuring an articles associated files has been 
discussed in [@dolfi_model_2014], where the authors introduce a "paper 
model" of reproducible research which consists of an MPI application 
used to illustrate how to organize a project. In [@brown_how_2014], 
the authors propose a similar approach based on the use of `make`, 
with the purpose of automating the generation of a PDF file. We extend 
these ideas by having our convention be centered around OSS 
development practices and include the notion of instant replicability 
by using docker and ansible.

In [@collberg_measuring_2014] the authors took 613 articles published 
in 13 top-tier systems research conferences and found that 25% of the 
articles are reproducible (under their reproducibility criteria). The 
authors did not analyze performance. In our case, we are interested 
not only in being able to rebuild binaries and run them but also in 
evaluating the performance characteristics of the results.

Containers, and specifically docker, have been the subject of recent 
efforts that try to alleviate some of the reproducibility problems in 
data science [@boettiger_introduction_2014]. Existing tools such as 
Reprozip [@chirigati_reprozip_2013] package an experiment in a 
container without having to initially implement it in one (i.e. 
automates the creation of a container from an "non-containerized" 
environment). This tool can be useful for researchers that aren't 
familiar with tools

# Conclusion

In the words of Karl Popper: "_the criterion of the scientific status 
of a theory is its falsifiability, or refutability, or testability_". 
The OSS development model has proven to be an extraordinary way for 
people around the world to collaborate in software projects. In this 
work, we apply it in an academic setting. By writing articles 
following the _Popper_ convention, authors can generate research that 
is easier to validate and replicate.

# Bibliography

<!-- hanged biblio -->

\noindent
\vspace{-2em}
\setlength{\parindent}{-0.22in}
\setlength{\leftskip}{0.2in}
\setlength{\parskip}{8pt}
