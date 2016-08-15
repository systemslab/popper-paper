---
title: "The Popper Convention: Making Reproducible Systems Evaluation Practical"
titlebanner: "ASPLOS Submission \\#390 - Confidential Draft - Do Not Distribute!!"
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
secPrefix: section
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
organizing an article's artifacts following a DevOps 
[@httermann_devops_2012 ; @loukides_what_2012] approach that allows 
researchers to make all the associated artifacts publicly available 
with the goal of easing the re-execution of experiments and validation 
of results. There are two main goals for Popper:

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
The availability of the artifacts does not guarantee the reproduction 
of results since a significant amount of manual work needs to be done 
after these have been downloaded. Additionally, large data 
dependencies cannot be uploaded since there is usually a limit on the 
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
datasets cannot be packaged; the experiment is a black-box without 
contextual information (e.g. history of modifications) that is hard to 
introspect, making difficult to build upon existing work; and 
packaging does not explicitly capture validation criteria.

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
@Fig:exp_workflow (top). The problem with current practices is that 
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

# The DevOps Toolkit {#sec:toolkit}

While is difficult to find a globally accepted definition of DevOps, 
for our purposes we use the term to refer to a set of common practices 
that have the goal of expediting the delivery of a software project, 
allowing to iterate as fast as possible on improvements and new 
features, without undermining the quality of the software product. In 
our work, we make the case for achieving the same outcome for academic 
articles, which can be seen as taking the idea of an executable paper 
and implementing it with a DevOps approach.

In this section we review and highlight salient features of the DevOps 
toolbox that makes it amenable to organize all the artifacts 
associated to an academic article. To guide our discussion, we refer 
to the generic experimentation workflow (top) in @Fig:exp_workflow, 
viewed through a DevOps looking glass (bottom). In @Sec:popper we 
analyze more closely the composability of these tools and describe 
general guidelines (the convention) on how to structure projects that 
make use of the DevOps toolbox.

## Version Control

Traditionally the content managed in a version-control system (VCS) is 
the project's source code; for an academic article the equivalent is 
the article's content: article text, experiments (code and data) and 
figures. The idea of keeping an article's source in a VCS is not new 
and in fact many people follow this practice [@brown_how_2014 ; 
@dolfi_model_2014]. However, this only considers automating the 
generation of the article in its final format (usually PDF). While this 
is useful, here we make the distinction between changing the prose of 
the paper, changing the parameters of the experiment (both its 
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
difficult. However, this does not exclude such research projects from 
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
same experiment on a new workload or compute platform. Although not 
usually done, in some cases researchers keep a chronological record on 
how experiments evolve over time (the analogy of the lab notebook in 
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
[@collberg_repeatability_2015]. The second main component on 
experimentation pipeline is the packaging of applications so that 
users don't have to. Software containers (e.g. Docker, OpenVZ or 
FreeBSD's jails) complement package managers by packaging all the 
dependencies of an application in an entire filesystem snapshot that 
can be deployed in systems "as is" without having to worry about 
problems such as package dependencies or specific OS versions. From 
the point of view of an academic article, these tools can be leveraged 
to package the dependencies of an experiment. Software containers like 
Docker have the great potential for being of great use in 
computational sciences [@boettiger_introduction_2014].

**Tools and services**: Docker [@merkel_docker_2014] automates the 
deployment of applications inside software containers by providing an 
additional layer of abstraction and automation of 
operating-system-level virtualization on Linux. Alternatives to Docker 
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

**Tools and services**: Aver is an example of a language and 
validation tool that allows authors to express and corroborate 
statements about the runtime metrics gathered of an experiment.

# The Popper Convention: A DevOps Approach to Producing Academic Papers {#sec:popper}

The goal for _Popper_ is to give researchers a common framework to 
reason, in a convened way, about how to structure all the dependencies 
and generated artifacts associated to an experiment. This convention 
provides the following unique features:

 1. Provides with a methodology (or experimentation protocol) for 
    generating self-contained experiments.
 2. Makes it easier for researchers to explicitly specify validation 
    criteria.
 3. Abstracts domain-specific experimentation workflows and 
    toolchains.
 4. Re-usable experiment templates that provide curated experiments 
    commonly used by a research community.

## Self-containment

We say that an experiment is Popper-compliant (or that it has been 
"Popperized") if all of the following is available, either directly or 
by reference, in one single source-code repository: experiment code, 
experiment orchestration code, reference to data dependencies, 
parametrization of experiment, validation criteria and results. In 
other words, a popper repository contains all the dependencies for an 
article, including its manuscript. The structure of a Popper repo is 
simple, there are `paper/` and `experiments/` folders, and every 
experiment has a `datasets/` folder in it.

```{#lst:dir .bash caption="Sample contents of a Popper repository."}
paper-repo
| README.md
| .travis.yml
| experiments
|   |-- myexp
|   |   |-- datasets/
|   |       |-- input-data.csv
|   |   |-- figure.png
|   |   |-- process-result.py
|   |   |-- setup.yml
|   |   |-- results.csv
|   |   |-- run.sh
|   |   |-- validations.aver
|   |    -- vars.yml
| paper
|   |-- build.sh
|   |-- figures/
|   |-- paper.tex
|    -- references.bib
```

An example paper project is shown in @Lst:dir. A paper repository is 
mainly composed of the article text and experiment orchestration 
logic. The actual code that gets executed by an experiment is not part 
of the repository. This, as well as any large datasets that are used 
as input to an experiment reside in their own repositories and are 
stored in the experiment folder of paper repository as references.

With all these artifacts available, the reader can easily deploy an 
experiment or rebuild the article's PDF that might include new 
results. A paper is written in any desired markup language. In the 
above listing we use LATeX as an example (`paper.tex` file). There is 
a `build.sh` command that generates the output format (e.g. `PDF`). 
For the experiment execution logic, each experiment folder contains 
the necessary information such as setup, output post-processing (data 
analysis) and scripts for generating an image from the results. The 
execution of the experiment will produce output that is either 
consumed by a post-processing script, or directly by the scripts that 
generate an image. The output can be in any format (CSVs, HDF, NetCDF, 
etc.), as long as it is versioned and referenced. An important 
component of the experiment logic is that it should assert the 
original assumptions made about environment (a `setup.yml` file in the 
example), for example, the operating system version (if the experiment 
assumes one). Also, it's important to parametrize the experiment 
explicitly (e.g. `vars.yml`), so that readers can quickly get an idea 
of what's the parameter space of the experiment and what they can 
modify in order to obtain different results. One common practice we 
follow is to place in every figure's caption a `[source]` link that 
points to the URL of the corresponding post-processing script in the 
version control web interface (e.g. GitHub[^github-ipy]).

[^github-ipy]: GitHub has the ability to render jupyter notebooks on 
its web interface. This is a static view of the notebook (as produced 
by the original author). In order to have a live version of the 
notebook, one has to instantiate a Binder or run a local notebook 
server.

## Automated Validation

Validation of experiments can be classified in two categories. In the 
first one, the integrity of the experimentation logic is checked using 
existing continuous-integration (CI) services such as TravisCI, which 
expects a `.travis.yml` file at the root folder that. This 
specification consists of a list of tests that get executed every time 
a new commit is added to the repository. This type of checks can 
verify that the paper can be built (generate the PDF correctly); that 
the syntax of orchestration files is correct to ensure that, if an 
experiment is changed, say, by adding a new variable, it can be 
executed without any issues; or checking that the post-processing 
routines can be executed without problems.

The second category of validations is related to the integrity of the 
experiment results. These domain-specific tests ensure that the claims 
made in the paper are valid for every re-execution of the experiment; 
analogous to performance regression tests done in software projects 
that can be implemented using the same class of tools. Alternatively, 
claims can also be corroborated as part of the analysis code. When 
experiments are not sensible to the effects of virtualized platforms, 
these assertions can be executed on public/free CI platforms (e.g. 
TravisCI runs tests in VMs). However, when results are sensible to the 
underlying hardware, it is preferable to leave this out of the CI 
pipeline and make them part of the post-processing routines of the 
experiment. In the example above, an `assertions.aver` file contains 
validations in the Aver [@jimenez_aver_2016] language that check the 
integrity of runtime performance metrics that claims make reference 
to. Examples of these type of assertions are: "the runtime of our 
algorithm is 10x better than the baseline when the level of 
parallelism exceeds 4 concurrent threads"; or "for dataset A, our 
model predicts the outcome with an error of 95%". More concrete 
examples are given in @Sec:cases.

When validating assertions that depend on the underlying hardware, 
i.e. that come from capturing runtime performance metrics, an 
important step is to corroborate that the baseline performance of the 
experiment for a new environment can be reproduced. While this is a 
similar test that can be codified using performance regression testing 
as mentioned in the above paragraph, we make the distinction since 
this step can be executed before any experiment runs. If the baseline 
performance cannot be reproduced, there is no point in executing the 
experiment. For example, the results of an experiment that originally 
ran on an environment consisting of HDDs, with a particular ratio of 
storage to network bandwidth where the bottleneck resides in storage, 
results will likely differ from those executed in another environment 
where the bottleneck is in the network (e.g. because storage is 
faster). Many of the commonly used orchestration tools incorporate 
functionality for obtaining "facts" about the environment, information 
that is useful to have when corroborating assumptions; other 
monitoring tools such as Nagios [@nagioscontributors_nagios_2016] can 
capture raw system-level performance; and existing frameworks such as 
baseliner are designed to obtain baseline profiles that are associated 
to experimental results. All these different sources of baseline 
performance characteristics can serve as a "fingerprint" of the 
underlying platform and can be given to tools such as Aver so that 
assertions about the environment are executed before an experiment 
runs, as a way of sanitizing the execution.

## Toolchain Agnosticism

We designed Popper as a general tool, applicable to a wide variety of 
environments, from cloud to HPC. Figure 2 In general, Popper can be 
applied in any scenario where a component (data, code, infrastructure, 
hardware, etc.) is referenceable, and where there is an underlying 
tool that consumes these IDs so that they can be acted upon (install, 
run, store, visualize, etc.). The core idea behind Popper is to borrow 
from the DevOps movement [@wiggins_twelvefactor_2011] the idea of 
treating every component as an immutable piece of information and 
provide referenceable scripts/components for the 
creation/execution/validation of experiments (in a convened structure) 
rather than leaving to the reader the daunting task of inferring how 
binaries/experiments were generated/configured.

We say that a tool is Popper-compliant if it has the following two 
properties:

 1. Assets can be be associated to unique IDs. Code, packages, 
    configurations, data, results, etc. can all be referenceable and 
    uniquely identified.
 2. The tool is scriptable (e.g. can be invoked in a CLI) and can act 
    upon given asset IDs.

In @Sec:toolkit we have provided a list of tools for every category of 
the generic experimentation workflow (@Fig:exp_workflow) that comply 
with the two properties given above. In order to illustrate better why 
these are important, we give examples of non-compliant tools 
(**TODO**: this list will be improved):

 * source-code management: Visual SourceSafe (VSS) or StarTeam
 * packaging: **TODO**.
 * manuscript: word.
 * experiment orchestration: **TODO**.
 * monitoring: a GUI-based thing (top or a Java-based one?)
 * viz: excel, https://github.com/densitydesign/raw

In general, tools that are hard to script e.g. because they don't 
provide a command-line interface (can only interact via GUI) or they 
only have a programmatic API for a non-interpreted language or, are 
"unpopperizable" tools.

## Experiment Templates

Researchers that decide to follow Popper are faced with a steep 
learning curve, especially if they have only used a couple of tools 
from the DevOps toolbox. To lower the entry barrier, we have developed 
a CLI tool[^link:cli] to help bootstrap a paper repository that 
follows the Popper convention.

As part of our efforts, we maintain a list of experiment templates 
that have been "popperized"[^link:templates]. These are end-to-end 
experiments that use a particular toolchain and for which execution, 
production of results and generation of figures has been implemented 
(see @Sec:cases for examples; each use case is available as an 
experiment in the templates repository). The CLI tool can list and 
show information about available experiments. Assuming a git 
repository has been initialized, the tool allows to add experiments to 
the repository (@Lst:poppercli).

```{#lst:poppercli .bash caption="Initialization of a Popper repo."}
$ cd mypaper-repo
$ popper init
-- Initialized Popper repo

$ popper experiment list
-- available templates ---------------
ceph-rados        proteustm  mpi-comm-variability
cloverleaf        gassyfs    zlog
spark-standalone  torpor     malacology

$ popper add torpor myexp
```

[^link:cli]: https://github.com/systemslab/popper/tree/master/popper
[^link:templates]: https://github.com/systemslab/popper-templates

# Use Cases {#sec:cases}

We now show use cases for different toolchains that illustrate how 
Popper is tool-agnostic. Due to space constraints we have to reduce 
the number of experiments we show for each use case. We refer the 
reader to this paper's Popper repository 
<https://github.com/systemslab/popper-paper/tree/asplos17/> for more 
detailed information about the experimental setup as well as more 
comprehensive results.

## Torpor: Quantifying Cross-platform Performance Variability

Reproducing systems experiments is sometimes challenging due to their 
sensitivity to the underlying hardware and low-level software stack 
(firmware and OS). In this use case we exemplify how an experiment 
that is potentially sensible to a customized version of the OS can be 
"Popperized", e.g. because it needs particular features of a custom 
kernel or specific drivers.

Torpor [@jimenez_characterizing_2016] is a workload- and 
architecture-independent technique for characterizing the performance 
of a computing platform. In short, Torpor works by executing a battery 
of micro-benchmarks and using these as the performance profile of a 
system. Given two profiles of two distinct platforms A and B, Torpor 
generates a variability range of B with respect to A. These 
variability profiles can then be used to predict the variability of 
any application running on B, that originally ran A. The goal is to 
predict as well as recreate performance of applications that run on 
newer (and faster) platforms using OS-level virtualization.

In this case, we take the experiment from 
[@jimenez_characterizing_2016] that quantifies the variability of a 
list of machines with respect to a 10 year old system. Due to space 
constraints, we only show the variability profile for one machine but 
results for all the other machines are available in this paper's 
repository. Since we're interested in "pinning" a particular kernel 
version[^notreally], a natural option is to use a virtual machine to 
package the experiment. Vagrant [@hashicorp_vagrant_2016] is a 
higher-level wrapper around virtualization software that provides the 
framework and configuration format (Ruby language scripts) to create 
and manage complete portable development environments.

The experiment folder contains all necessary files to easily invoke it 
and generate figures. A bash `run.sh` script installs Vagrant if it's 
not present; downloads the VM or builds it if links are broken; and 
lastly executes the experiment. Once the VM runs, the results are 
placed in the folder where the experiment was invoked (CSV files). The 
analysis is done in Gnuplot, which in this case runs on the host but 
could be packaged in a Docker container or another VM. The result of 
executing the Gnuplot script generates @Fig:torpor-variability. As 
mentioned before, the goal of Popper is to provide self-contained 
experiments with minimal 3rd party and effort requirements.

<!-- Toolchain: AsciiDoc, Vagrant, Bash and Gnuplot -->

![\[[source](https://github.com/systemslab/popper-paper/tree/asplos17/experiments/torpor)\] 
Variability profile of benchmarks.
](experiments/torpor/variability_profile.png){#fig:torpor-variability}

[^notreally]: Strictly speaking, these Torpor experiment doesn't 
necessarily depend on a particular Linux version but we assume it does 
to illustrate the need of running a specific version of the kernel.

## GassyFS: Scalability of an In-memory Filesystem

This use case illustrates how multi-node experiments can be easily 
ported between multiple platforms. It also exemplifies how the 
validation criteria of an experiment can be made explicit and be 
automatically checked with currently available tools.

GassyFS [@watkins_gassyfs_2016] is a new prototype filesystem system 
that stores files in distributed remote memory and provides support 
for checkpointing file system state. The core of the file system is a 
user-space library that implements a POSIX file interface. File system 
metadata is managed locally in memory, and file data is distributed 
across a pool of network-attached RAM managed by worker nodes and 
accessible over RDMA or Ethernet. Applications access GassyFS through 
a standard FUSE mount, or may link directly to the library to avoid 
any overhead that FUSE may introduce. By default all data in GassyFS 
is non-persistent. That is, all metadata and file data is kept in 
memory, and any node failure will result in data loss. In this mode 
GassyFS can be thought of as a high-volume tmpfs that can be 
instantiated and destroyed as needed, or kept mounted and used by 
applications with multiple stages of execution. The differences 
between GassyFS and tmpfs become apparent when we consider how users 
deal with durability concerns.

Although GassyFS is simple in design, it is relatively complex to 
setup. The combinatorial space of possible ways in which the system 
can be compiled, packaged and configured is large. For example, 
current version of GCC (4.9) has approximately $10^{8}$ possible ways 
of compiling a binary. For the version of GASNet that we use (2.6), 
there are 64 flags for additional packages and 138 flags for 
additional features[^more]. To mount GassyFS, we use FUSE, which can 
be given more than 30 different options, many of them taking multiple 
values.

[^more]: These are the flags that are documented. There are many more 
that can be configured but not shown in the official documentation.

![\[[source](https://github.com/systemslab/popper-paper/tree/asplos17/experiments/gassyfs/visualize.ipynb)\] 
Scalability of GassyFS as the number of nodes in the GASNet cluster 
increases. The workload in question compiles `git`.
](experiments/gassyfs/git-multinode.png){#fig:gassyfs-git}

In figure @Fig:gassyfs-git we show one of multiple experiments that 
evaluate the performance of GassyFS. We note that while the 
performance numbers obtained are relevant, they are not our main 
focus. Instead, we put more emphasis on the goals of the experiments, 
how we can reproduce results on multiple environments with minimal 
effort and how we can ensure the validity of the results.

In this experiment we aim to evaluate the scalability of GassyFS, i.e. 
how it performs when we increase the number of nodes in the underlying 
GASNet-backed FUSE mount. Figure @Fig:gassyfs-git shows the results of 
compiling `git` on GassyFS. We observe that once the cluster gets to 2 
nodes, performance degrades sublinearly with the number of nodes. This 
is expected for workloads such as the one in question. The following 
Aver assertion is used to check the integrity of this result:

```sql
  when
    workload=* and machine=*
  expect
    sublinear(nodes,time)
```

The above expresses our expectation of GassyFS performing sublinearly 
with respect to the number of nodes. After the experiment runs, Aver 
is invoked to test the above statement against the experiment results 
obtained.

## Numerical Weather Prediction: A Data-centric Use Case

In this use case we show how to bootstrap a data science paper that 
follows the Popper convention using the Popper-CLI tool. Popper in 
this scenario is followed so that datasets are properly referenced and 
analysis scripts used to process data are versioned and associated to 
an article.

**Initializing a Popper Repository**: Our Popper-CLI tool assumes a 
git repository exists. Given a git repo, we invoke the Popper-CLI tool 
and initialize the Popper files by issuing a `popper init` command in 
the root of the git repository. This creates a `.popper.yml` file that 
contains configuration options for the CLI tool. This file is 
committed to the paper (git) repository.

**Adding a New Experiment**: As mentioned before, we maintain a list 
of experiment templates that have been "Popperized" (@Lst:poppercli). 
In this example we want to analyze data from an experiment in the area 
of meteorological sciences (a template created as part of the [Big 
Weather Web project](http://bigweatherweb.org)). For this experiment, 
sensor data has been generated elsewhere and we are interested in 
properly referencing the dataset, i.e. dataset creation is not part of 
the experiment. Additionally, the analysis runs on a single machine. 
Other types of data science projects might involve generating their 
input datasets and/or process data in a cluster of machines. Popper 
still can be followed in these scenarios, as shown in previous 
sections.

```{#lst:bootstrap .bash caption="A Data Analysis Experiment."}
$ popper add jupyter-bww airtemp-analysis
$ cd experiments/airtemp-analysis
$ dpm install datapackages/air-temperature
$ ./visualize.sh
```

This data analysis experiment consists of one dataset and a Jupyter 
notebook. Relatively large datasets aren't managed well by git, so 
they should be managed by other tools. We use `dpm` in this case 
(third line in @Lst:bootstrap). Once the datasets are downloaded, one 
can open the notebook to visualize and interact with the data analysis 
of this experiment. The last line above opens a browser and points it 
to the notebook.

**Documenting the Experiment**: After we're done with our experiment, 
we might want to document it and add a paper. The Popper-CLI also 
provides with manuscript templates. We can use the generic `article` 
latex template or other more domain-specific ones. To display the 
available templates we do `popper paper list`. In this example we'll 
use the latex template for articles that appear in the [Bulletin of 
the American meteorological Society 
(BAMS)](http://journals.ametsoc.org/loi/bams).

Let's assume we have a new section in the LATeX file where we describe 
our experiment. We make use of the figure that we have generated and 
reference it from the LATeX file. We then regenerate the article (with 
a `build.sh` command inside the `paper` folder) and see the new image 
like the one shown in @Fig:bww-airtempanalysis.

![\[[source](https://github.com/systemslab/popper-paper/tree/asplos17/experiments/bww-airtemp/visualize.ipynb)\] 
The output of analysis of weather prediction data. The output comes 
from data processed with the `xarray` Python library. The data 
corresponds to the NCEP/NCAR Reanalysis 1.
](experiments/bww-airtemp/air-temperature.png){#fig:bww-airtempanalysis}

**Documenting Changes to Experiments**: The paper repository is the 
analogy to the lab notebook in experimental science. There are many 
ways in which these changes can be registered in the form of code 
repository commits. A couple of tips:

  * Make changes small. Avoid having large commits since that makes it 
    harder to document.
  * Separate commits that change the logic of the experiment and 
    analysis, from the ones that record changes to results.
  * Commit messages should describe in as much detail as possible the 
    changes to the experiment, or the new results being added to the 
    repository.


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
aspects of it, making it practical to "stand in the shoulders of 
giants" by building upon the work of the community to improve the 
state-of-the-art without having to start from scratch every time.

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
communicate reproducible science. By having popular tools such as 
Docker/Ansible as a lingua franca for researchers, and Popper to guide 
them in how to structure their paper repos, we can expedite 
collaboration and at the same time benefit from all the new advances 
done in the cloud-computing/DevOps world.

## Perfect is the enemy of good

No matter how hard we try, there will always be something that goes 
wrong. The context of systems experiments is often very complex and 
that complexity is likely to increase in the future. Perfect 
repeatability will be very difficult to achieve. Recent empirical 
studies in computer systems [@hoefler_scientific_2015 ; 
@collberg_repeatability_2015] have brought attention to the main 
issues that permeate the current practice of our research communities. 
We don't aim at perfect repeatability but to minimize the issues we 
face and to have a common language that can be used while 
collaborating to fix all these reproducibility issues.

## Drawing the line between packaging and deployment

Figuring out where something should be in the deploy framework (e.g., 
Ansible) or in the package framework (e.g., Docker) must be 
standardized by the users of the project. One could implement Popper 
entirely with Ansible but this introduces complicated playbooks and 
permantently installs packages on the host. Alternatively, one could 
use Docker to orchestrate services but this requires "chaining" images 
together. This process is hard to develop since containers must be 
recompiled and shared around the cluster. We expect that communities 
of practice will find the right balance between these technologies, 
e.g. by improving on the co-design of Ansible playbooks and Docker 
images within their communities.

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
paper repository. They also usually misunderstand how OS-level 
virtualization works and do not realize that there is no performance 
hit, no network port remapping, and no layers of indirection. Lastly, 
first encounters with Docker require users to understand that Docker 
containers do not represent baremetal hardware but immutable 
infrastructure, i.e. one cannot ssh into them to start services, one 
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

Almost all publications about systems experiments underreport the 
context of an experiment, making it very difficult for someone trying 
to reproduce the experiment to control for differences between the 
context of the reported experiment and the reproduced one. Due to 
traditional intractability of controlling for all aspects of the setup 
of an experiment systems researchers typically strive for making 
results "understandable" by applying sound statistical analysis to the 
experimental design and analysis of results 
[@hoefler_scientific_2015]. The Popper Convention makes controlled 
experiments practical by managing all aspects of the setup of an 
experiment and leveraging shared infrastructure.

## Providing Performance Profiles Alongside Experimental Results

This allows to preserve the performance characteristics of the 
underlying hardware that an experiment executed on and facilitates the 
interpretation of results in the future.

# Conclusion

In the words of Karl Popper: "_the criterion of the scientific status 
of a theory is its falsifiability, or refutability, or testability_". 
The OSS development model and the DevOps practice have proven to be an 
extraordinary way for people around the world to collaborate in 
software projects. In this work, we apply them in an academic setting. 
As the use cases presented here showed, by writing articles following 
the _Popper_ convention, authors can improve their personal workflows, 
while at the same time generate research that is easier to validate 
and replicate. The Popper-CLI tool is available at 
<https://github.com/systemslab/popper>.

# Bibliography

<!-- hanged biblio -->

\noindent
\vspace{-2em}
\setlength{\parindent}{-0.22in}
\setlength{\leftskip}{0.2in}
\setlength{\parskip}{8pt}
