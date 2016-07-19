---
title: "The Popper Convention: Making Reproducible Systems Evaluation 
Practical"
author:
- name: "  "
  affiliation: "  "
  email: "  "
#- name: "Ivo Jimenez, Michael Sevilla, Noah Watkins, Carlos Maltzahn"
#  affiliation: "_UC Santa Cruz_"
#  email: "`{ivo,msevilla,jayhawk,carlosm}@cs.ucsc.edu`"
number-of-authors: 4
abstract: |
  Independent validation of experimental results in the field of 
  systems research is a challenging task, mainly due to changes and 
  differences in software and hardware in computational environments. 
  Recreating an environment that resembles the original is difficult 
  and time-consuming. In this paper we introduce _Popper_, a 
  convention based on a set of modern open source software (OSS) 
  development principles for producing scientific publications. 
  Concretely, we make the case for treating an article as an OSS 
  project following a DevOps approach and applying software 
  engineering best-practices to manage its associated artifacts and 
  maintain the reproducibility of its findings. Popper leverages 
  existing cloud-computing infrastructure and DevOps tools to produce 
  academic articles that are easy to validate, reproduce and extend. 
  We present three use cases that illustrate the usefulness of this 
  approach. We show how, by following the _Popper_ convention, 
  re-executing experiments on multiple platforms is more practical, 
  allowing reviewers and students to quickly get to the point of 
  getting results without relying on the original author's 
  intervention.
documentclass: sigplanconf
sigplanconf: true
classoption: preprint
fontsize: 10pt
monofont-size: scriptsize
numbersections: true
substitute-hyperref: true
usedefaultspacing: true
fontfamily: times
linkcolor: black
figPrefix: Fig.
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
looking at provenance information about the experiment, re-evaluates 
the questions that the original experiment addressed and builds upon 
the results of the original study.

Independently validating experimental results in the field of computer 
systems research is a challenging task [@freire_computational_2012 ; 
@fursin_collective_2013]. Recreating an environment that resembles the 
one where an experiment was originally executed is a time-consuming 
endeavour [@collberg_repeatability_2015 ; @hoefler_scientific_2015]. 
In this work, we revisit the idea of an executable paper 
[@strijkers_executable_2011 ; @dolfi_model_2014 ; 
@leisch_executable_2011 ; @kauppinen_linked_2011], which proposes the 
integration of executables and data with scholarly articles to help 
facilitate its reproducibility, but look at implementing it in today's 
cloud-computing world by treating an article as an open source 
software (OSS) project. We introduce _Popper_, a convention for 
organizing an article's artifacts following a DevOps[^devops] approach 
that allows researchers to make all the associated artifacts publicly 
available with the goal of easing the re-execution of experiments and 
validation of results. There are two main goals for Popper:

 1. It should be usable in as many research projects as possible, 
    regardless of their domain.
 2. It should abstract the underlying technologies.

This paper describes our experiences with the Popper convention which 
we have successfully followed to aid in producing papers and classroom 
lessons that are easy to reproduce. This paper makes the following 
contributions:

  * An analysis of how the DevOps practice can be repurposed to an 
    academic article;
  * Popper: A methodology for writing academic articles and associated 
    experiments following the DevOps model;
  * Popper-CLI: an experiment bootstrapping tool that makes 
    Popper-compliant experiments readily available to researchers; and
  * Three use cases detailing how to follow Popper in practice.

The use cases illustrate the benefits of following the Popper 
convention: it brings order to personal research workflows and makes 
it practical for others to re-execute experiments on multiple 
platforms with minimal effort, without having to speculate on what the 
original authors did to compile and configure the system; and shows 
how automated performance regression testing aids in maintaining the 
reproducibility integrity of experiments.

[^devops]: https://en.wikipedia.org/wiki/DevOps

# Common Practice

## Ad-hoc Personal Workflows

A typical practice is the use of custom bash scripts to automate some 
of the tasks of executing experiments. From the point of view of 
researchers, having an ad-hoc framework results in more efficient use 
of their time, or at least that's the belief. Since these are 
personalized scripts, they usually hard-code many of the parameters or 
paths to files in the local machine. Worst of all, a lot of the 
contextual information is in the mind of researchers. Without a list 
of guiding principles, going back to an experiment, even for the 
original author on the same machine, represents a time-consuming task.

## Sharing source code

Version-control systems give authors, reviewers and readers access to 
the same code base [@brown_how_2014] but the availability of source 
code does not guarantee reproducibility 
[@collberg_repeatability_2015]; code may not compile, and even it 
does, results may differ due to differences coming from other 
components in the software stack. While sharing source code is 
beneficial, it leaves readers with the daunting task of recompiling, 
reconfiguring, deploying and re-executing an experiment. Things like 
compilation flags, experiment parameters and results is fundamental 
contextual information for re-executing an experiment that is 
unavailable.

## Experiment repositories

An alternative to sharing source code is experiment repositories 
[@stodden_researchcompendiaorg_2015 ; @stodden_runmycodeorg_2012 ; 
@roure_designing_2007]. These allow researchers to upload artifacts 
associated to a paper. Similarly to code repositories, one of the main 
problems is the lack of automation and structure for the artifacts. 
The availability of the artifacts doesn't guarantee the reproduction 
of results since a significant amount of manual work needs to be done 
after these have been downloaded. Additionally, large data 
dependencies can't be uploaded since there is usually a limit on the 
artifact file size.

## Virtual Machines

A Virtual Machine (VM) can be used to partially address the 
limitations of only sharing source code. However, in the case of 
systems research where the performance is the subject of study, the 
overheads in terms of performance (the hypervisor "tax") and 
management (creating, storing and transferring) can be high and, in 
some cases, they cannot be accounted for easily [@clark_xen_2004 ; 
@klimeck_nanohuborg_2008]. An alternative to this is OS-level 
virtualization [@jimenez_role_2015].

## Experiment Packing

Experiment packing entails tracing an experiment at runtime to capture 
all its dependencies and generating a package that can be shared with 
others [@chirigati_reprozip_2016 ; @guo_burrito_2012 ; 
@pham_sharing_2015 ; @davison_sumatra_2014]. Experiment packing is an 
automated way of creating a virtual machine or environment and thus 
suffers from the same limitations: external dependencies such as large 
datasets can't be packaged; the experiment is a black-box without 
contextual information (e.g. history of modifications) that is hard to 
introspect, making difficult to build upon existing work; and 
packaging doesn't explicitly capture validation criteria.

## _Eyeball_ Validation

Assuming the reader is able to recreate the environment of an 
experiment, validating the outcome requires domain-specific expertise 
in order to determine the differences between original and recreated 
environments that might be the root cause of any discrepancies in the 
results [@jimenez_tackling_2015a ; @freire_computational_2012 ; 
@donoho_reproducible_2009]. Additionally, reproducing experimental 
results when the underlying hardware environment changes is 
challenging mainly due to the inability to predict the effects of such 
changes in the outcome of an experiment [@saavedra-barrera_cpu_1992 ; 
@woo_splash2_1995]. In this case validation is typically done by 
"eyeballing" figures and the description of experiments in a paper, a 
subjective task, based entirely on the intuition and expertise of 
domain-scientists.

## Desiderata for a New Methodology

A diagram of a generic experimentation workflow is shown in 
@fig:exp_workflow (top). The problem with current practices is that 
each of them partially cover the workflow. For example, sharing source 
code only covers the first task (source code); experiment packing only 
covers the second one (packaging); and so on. Based on this, we see 
the need for a new methodology that has the following properties:

  * Reproducible from the get-go without incurring in extra work for 
    the researcher. To the contrary, it should require the same or 
    less effort but in a convened way.
  * Improve the personal workflows of scientists by having a common 
    methodology that works for as many projects as possible and that 
    can be used as the basis of collaboration.
  * Capture the end-to-end workflow in a modern (DevOps) way, 
    including the history of changes that are made to an article 
    throughout its lifecycle.
  * Make use of existing tools (don't reinvent the wheel!). The DevOps 
    toolkit is already comprehensive and easy to use.
  * Take into account large datasets.
  * Capture validation criteria in an explicit manner so that 
    subjective evaluation of results of a re-execution is minimized.
  * Result in experiments that are amenable to improvement and allows 
    easy collaboration, as well as making it easier to build upon 
    existing work.

# A DevOps Approach to Producing Academic Papers

DevOps is a practice that emphasizes the collaboration and 
communication of both software developers and other 
information-technology (IT) professionals while automating the process 
of software delivery and infrastructure changes. It aims at 
establishing a culture and environment where building, testing, and 
releasing software, can happen rapidly, frequently, and more reliably. 
Because DevOps is a cultural shift, there is no single toolset, rather 
a set or "DevOps toolchain" consisting of multiple tools, where each 
fits into one or more categories, which is reflective of the software 
development and delivery process.

In this section, we list the key reasons why the process of 
implementing experiments and writing scientific papers is so amenable 
to a DevOps approach. The goal of our work is to apply these in the 
academic setting in order to enjoy from the same benefits: build upon 
the work of (and openly collaborate with) others to advance the state 
of the art. To guide our discussion, we will refer to the generic 
experimentation workflow (top) in @fig:exp_workflow viewed through the 
DevOps (bottom).

## Version Control

Traditionally the content managed in a version-control system (VCS) is 
the project's source code; for an academic article the equivalent is 
the article's content: article text, experiments (code and data) and 
figures. The idea of keeping an article's source in a VCS is not new 
and in fact many people follow this practice [@brown_how_2014 ; 
@dolfi_model_2014]. However, this only considers automating the 
generation of the article in its final format (usually PDF). While this 
is useful, here we make the distinction between changing the prose of 
the pape, changing the parameters of the experiment (both its 
components and its configuration), as well as storing the experiment 
results.

Ideally, one would like to version-control the entire end-to-end 
pipeline for all the experiments contained in an article. With the 
advent of cloud-computing, this is possible for most research 
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

**Tools and services**: git, svn and mercurial are popular VCS tools. 
GitHub and BitBucket are web-based Git repository hosting services. 
They offer all of the distributed revision control and source code 
management (SCM) functionality of Git as well as adding their own 
features. They give new users the ability to look at the entire 
history of the project and its artifacts.

## Package Management

![A generic experimentation workflow (top) typically followed by 
researchers in projects with a computational component. Some of the 
reasons to iterate (backwards-going arrows) are: fixing a bug in the 
code of a system, changing a parameter of an experiment or running the 
same experiment a new type of data or platform. Although not usually 
done, in some cases researchers keep a chronological record on how 
experiments evolve over time (the analogy of the lab notebook in 
experimental sciences). The bottom half represents the same workflow 
viewed through a DevOps looking glass. The logos correspond to 
commonly used tools from the "DevOps toolkit". From left-to-right, 
top-to-bottom: git, mercurial, subversion (code); docker, vagrant, 
spack, nix (packaging); git-lfs, datapackages, artifactory, archiva 
(input data); bash, ansible, puppet, slurm (execution); git-lfs, 
datapackages, icinga, nagios (output data and runtime metrics); 
jupyter, paraview, travis, jenkins (analysis, visualization and 
continuous integration); restructured text, latex, asciidoctor and 
markdown (manuscript); gitlab, bitbucket and github (experiment 
changes).
](figures/devops_approach.png){#fig:exp_workflow}

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

## Multi-node Orchestration

Experiments that require a cluster need a tool that automatically 
manages binaries and updates packages across machines. Traditionally, 
this has been done with an ad-hoc bash script but for experiments that 
are continually tested there needs to be an automated solution.

**Tools and services**: Ansible is a configuration management utility 
for configuring and managing computers, as well as deploying and 
orchestrating multi-node applications. Similar tools include Puppet, 
Chef, Salt, among others.

## Bare-metal-as-a-Service

For experiments that cannot run on consolidated infrastructures due to 
noisy-neighborhood phenomena (e.g. EC2), bare-metal as a service is an 
alternative.

**Tools and services**: Cloudlab [@ricci_introducing_2014], Chameleon 
and PRObE [@gibson_probe_2013] are NSF-sponsored infrastructures for 
research on cloud computing that allows users to easily provision 
bare-metal machines to execute multi-node experiments. Some cloud 
service providers such as Amazon allow users to deploy applications on 
bare-metal instances.

## Continuous Integration

Continuous Integration (CI) is a development practice that requires 
developers to integrate code into a shared repository frequently with 
the purpose of catching errors as early as possible. The experiments 
associated to an article is not absent of this type of issues. If an 
experiment's findings can be codified in the form of a unit test, this 
can be verified on every change to the article's repository.

**Tools and services**: Travis CI is an open-source, hosted, 
distributed continuous integration service used to build and test 
software projects hosted at GitHub. Alternatives to Travis CI are 
CircleCI, CodeShip. Other on-premises solutions exist such as Jenkins.

## Automated Performance Regression Testing

OSS projects such as the Linux kernel go through rigorous performance 
testing [@intel_linux_2016] to ensure that newer version don't 
introduce any problems. Performance regression testing is usually an 
ad-hoc activity but can be automated using high-level languages 
[@jimenez_aver_2016] or statistical techniques 
[@nguyen_automated_2012].

**Tools and services**: Aver is an example of a language and tool that 
allows authors to express and validate statements on top of metrics 
gathered at runtime.

## Dataset Management

Some experiments involve the processing of large input, intermediary 
or output datasets. While possible, traditional version control tools 
such as Git were not designed to store large binary files. A proper 
artifact repository client or dataset management tool can take care of 
handling data dependencies.

**Tools and services**: Examples are Apache Archiva 
[@apachearchivacontributors_archiva_2016], Git-LFS [@github_git_2016], 
Datapackages [@openknowledgeinternational_data_2016] or Artifactory 
[@jfrog_artifactory_2016].

## Data Analysis and Visualization

Once an experiment runs, the next task is to analyze and visualize 
results.

**Tools and services**: Jupyter notebooks run on a web-based 
application. It facilitates the sharing of documents containing live 
code (in Julia, Python or R), equations, visualizations and 
explanatory text. Other domain-specific visualization tools can also 
fit into this category. [Binder](mybinder.org) is an online service 
that allows one to turn a GitHub repository into a collection of 
interactive Jupyter notebooks so that readers don't need to deploy web 
servers themselves. Alternatives to Jupyter are Gnuplot, Zeppelin and 
Beaker. Other scientific visualization such as Paraview tools can also 
fit in this category.

# The Popper Convention

_Popper_ assists in the creation of articles that are developed as an 
OSS project. It provides the following unique features:

 1. Abstract research workflows and provide a tool that is agnostic of 
    specific tools.
 2. Works for commonly used toolchains.
 3. Embrace a methodology for generating self-contained experiments.
 4. Provide with re-usable experiment templates to minimize the time 
    taken to get a researcher up to speed with a research project.
 5. Automated Validation

![End-to-end workflow for an article that follows the Popper 
convention.](figures/wflow.png)

## Self-containment

A popper repository contains all the dependencies for an article, 
including its manuscript (Figure 2). There are `paper/` and 
`experiments/` folders, and every experiment has a `datasets/` folder 
in it.

```bash
paper-repo
| experiments
|   |-- myexp
|   |   |-- run
|   |   |-- script.py
|   |    -- figure.png
|   paper
|   |-- build
|   |-- figures
|    -- paper.tex
```

In the remaining of this paper we use GitHub, Docker, Binder, 
CloudLab, Travis CI and Aver as the tools/services for every component 
described in the previous section. As stated in goal 2, any of these 
should be swappable for other tools, for example: VMs instead of 
Docker; Puppet instead of Ansible; Jenkins instead of Travis CI; and 
so on and so forth. Our approach can be summarized as follows:

  * Github repository stores all details for the paper. It stores the 
    metadata necessary to build the paper and re-run experiments. 
  * Docker images capture the experimental environment, packages and 
    tunables.
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

### Organizing Files

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

When validating performance, an important component is to see the 
baseline performance of the experimental environment we are running 
on. Ansible has a way of obtaining "facts" about machines that is 
useful to have when validating results. Also, baseliner profiles that 
are associated to experimental results are a great way of asserting 
assumptions about the environment. baseliner is composed of multiple 
docker images that measure CPU, memory, I/O and network raw 
performance of a set of nodes. We execute baseliner on multi-node 
setups and make the profiles part of the results since this is the 
fingerprint of our execution. This also gives us an idea of the 
relationship among the multiple subsystems (e.g. 10:1 of network to 
IO).

### Organizing Dependencies

A paper repo is mainly composed of the article text and experiment 
orchestration logic. The actual code that gets executed by an 
experiment is not part of the paper repository. Similarly for any 
datasets that are used as input to an experiment. These dependencies 
should reside in their own repositories and be referenced in an 
experiment playbook.

#### Executables

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

#### Datasets

Input/output files should be also versioned. For small datasets, we 
can can put them in the git repository of the paper. For large 
datasets we can use `git-lfs`.

### Automated Validation

This is automated

## Toolchain-agnosticism

We designed Popper as a general tool, applicable to a wide variety of 
environments, from cloud to HPC. Figure 2 In general, Popper can be 
applied in any scenario where a component (data, code, infrastructure, 
hardware, etc.) is referenceable, and where there is an underlying 
tool that consumes these IDs so that they can be acted upon (install, 
run, store, visualize, etc.). The core idea behind Popper is to borrow 
from the DevOps movement the idea of treating every component as an 
immutable piece of information and provide referenceable 
scripts/components for the creation/execution/validation of 
experiments (in a convened structure) rather than leaving to the 
reader the daunting task of inferring how binaries/experiments were 
generated/configured.

### Popper-compliant Tools

Examples of non-compliant tools:

 * source-code management: Visual SourceSafe (VSS) or StarTeam
 * packaging: virtualbox
 * manuscript: word
 * viz: excel, https://github.com/densitydesign/raw

## Experiment Templates

We also have templates for papers.

# Use Cases

We now show use cases for three different toolchains that are commonly 
used.

## Ceph Scalability Experiment

Toolchain: Markdown, Docker, Ansible, Gnuplot and Aver

## MPI Performance Variability

Toolchain: Latex, Spack, Slurm and Paraview

Use case: Kathryn's LULESH experiment 
<http://dl.acm.org/citation.cfm?id=2503247>

## BAMS

Toolchain: AsciiDoc, Vagrant, Bash and Jupyter

# Discussion

## We did well for 50 years. Why fix it?

Shared infrastructures "in the cloud" are becoming the norm and enable 
new kinds of sharing, such as experiments, that were not practical 
before. Thus, the opportunity of these services goes beyond just 
economies of scale: by using conventions and tools to enable 
reproducibility, we can dramatically increase the value of scientific 
experiments for education and for research. The Popper Convention 
makes not only the result of a systems experiment available but the 
entire experiment and allows researchers to study and reuse all 
aspects of it.

## The power of "crystallization points."

Docker images, Ansible playbooks, CI unit tests, Git repositories, and 
Jupyter notebooks are all exemples of artifacts around which 
broad-based efforts can be organized. Crystallization points are 
pieces of technology, and are intended to be easily shareable, have 
the ability to grow and improvie over time, and ensure buy-in from 
researchers and students. Examples of very successful crystallization 
points are the Linux kernel, Wikipedia, and the Apache Project. 
Crystallization points encode community knowledge and are therefore 
useful for leveraging past research efforts for ongoing research as 
well as education and training. They help people to form abstractions 
and common understanding that enables them to more effectively 
communicate reproducible science. By having docker/ansible as a lingua 
franca for researchers, and Popper to guide them in how to structure 
their paper repos, we can expedite collaboration and at the same time 
benefit from all the new advances done in the cloud-computing/DevOps 
world.

## Perfect is the enemy of good

No matter how hard we try, there will always be something that goes 
wrong. The context of systems experiments is often very complex and 
that complexity is likely to increase in the future. Perfect 
repeatability will be very difficult to achieve. We don't aim at 
perfect repeatability but to minimize the issues we face and have a 
common language that can be used while collaborating to fix all these 
reproducibility issues.

## Drawing the line between deploy and packaging

Figuring out where something should be in the deploy framework (e.g., 
Ansible) or in the package framework (e.g., Docker) must be 
standardized by the users of the project. One could implement Popper 
entirely with Ansible but this introduces complicated playbooks and 
permantently installs packages on the host. Alternatively, one could 
use Docker to orchestrate services but this requires "chaining" images 
together. This process is hard to develop since containers must be 
recompiled and shared around the cluster. We expect that communities 
of practice will find the right balance between these technologies by 
improving on the co-design of Ansible playbooks and Docker images 
within their communities.

## Usability is the key to make this work

The technologies underlying the DevOps development model are not new. 
However, the open-source software community has significantly 
increased the usability of the tools involved. Usability is the key to 
make reproducibility work: it is already hard enough to publish 
scientific papers, so in order to make reproducibility even practical, 
the tools have to be extremely easy to use. The Popper Convention 
enables systems researchers to leverage the usability of DevOps tools.

However, with all great advances in usability, scientists still have 
to get used to new concepts these tools introduce. In our experience, 
experimental setups that do not ensure any reproducibility are still a 
lot easier to create than the ones that do. Not everyone knows git and 
people are irritated by the number of files and submodules in the 
paper repo. They also usuaually misunderstand how OS-level 
virtualization works and do not realize that there is no performance 
hit, no network port remapping, and no layers of indirection. Lastly, 
first encounters with Docker require users to understand that Docker 
containers do not represent baremetal hardware but immutable 
infrastructure, i.e. one can't ssh into them to start services, one 
need to have a service per image, and one cannot install software 
inside of them and expect those installations to persist after 
relaunching a container.

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

## Controlled Experiments become Practical

Almost all publications about systems experiments underreport the context of an
experiment, making it very difficult for someone trying to reproduce the experiment
to control for differences between the context of the reported experiment and the
reproduced one. Due to traditional intractability of controlling for all aspects of
the setup of an experiment systems researchers typically strive for making results
"understandable" by applying sound statistical analysis to the experimental design
and analysis of results [@hoefler_scientific_2015].

The Popper Convention makes controlled experiments practical by managing all aspects of the setup of an experiment and leveraging shared infrastructure.


## Providing Performance Profiles Alongside Experimental Results

This allows to preserve the performance characteristics of the 
underlying hardware that an experiment executed on and facilitates the 
interpretation of results in the future.

<!--
## Handling of results

We might need to find another way of managing experimental results. 
Putting results on git won't scale. There's also the issue of naming 
and experiment metadata.
-->

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
