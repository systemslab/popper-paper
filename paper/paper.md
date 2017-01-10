---
title: "The Popper Convention: Making Reproducible Systems Evaluation Practical"
author:
- name: "Ivo Jimenez, Michael Sevilla, Noah Watkins, Carlos Maltzahn"
  affiliation: "_UC Santa Cruz_"
  email: "`<ivo,msevilla,jayhawk,carlosm>@soe.ucsc.edu`"
- name: "Jay Lofstead"
  affiliation: "_Sandia National Laboratories_"
  email: "`gflofst@sandia.gov`"
- name: "Kathryn Mohror"
  affiliation: "_Lawrence Livermore National Laboratory_"
  email: "`kathryn@llnl.gov`"
- name: "Andrea Arpaci-Dusseau, Remzi Arpaci-Dusseau"
  affiliation: "_UW Madison_"
  email: "`<dusseau,remzi>@cs.wisc.edu`"
number-of-authors: 4
abstract: |
  Independent validation of experimental results in the field of 
  systems research is a challenging task, mainly due to differences in 
  software and hardware in computational environments. Recreating an 
  environment that resembles the original is difficult and 
  time-consuming. In this paper we introduce _Popper_, a convention 
  based on a set of modern open source software (OSS) development 
  principles for generating reproducible scientific publications. 
  Concretely, we make the case for treating an article as an OSS 
  project following a DevOps approach and applying software 
  engineering best-practices to manage its associated artifacts and 
  maintain the reproducibility of its findings. Popper leverages 
  existing cloud-computing infrastructure and DevOps tools to produce 
  academic articles that are easy to validate, reproduce and extend. 
  We present a use case that illustrate the usefulness of this 
  approach. We show how, by following the _Popper_ convention, 
  re-executing experiments on multiple platforms is more practical, 
  allowing reviewers and researchers quickly get to the point of 
  getting results without relying on the original author's 
  intervention.
documentclass: ieeetran
ieeetran: true
classoption: "conference,compsocconf"
monofont-size: scriptsize
numbersections: true
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
facilitate its reproducibility. Our approach is to implement it in 
today's cloud-computing world by treating an article as an open source 
software (OSS) project. We introduce _Popper_, a convention for 
organizing an article's artifacts following a DevOps 
[@httermann_devops_2012] approach that allows researchers to make all 
associated artifacts publicly available with the goal of maximizing 
automation in the re-execution of experiments and validation of 
results. There are two main goals for Popper:

 1. It should be usable in as many research projects as possible, 
    regardless of their domain.
 2. It should abstract underlying technologies without requiring a 
    strict set of tools, making it possible to apply it on multiple 
    toolchains.

This paper describes our experiences with the Popper convention which 
we have successfully followed to aid in producing papers and classroom 
lessons that are easy to reproduce. This paper makes the following 
contributions:

  * An analysis of how the DevOps practice can be repurposed to an 
    academic article (@Sec:common-practice and @Sec:toolkit);
  * Popper: A methodology for writing academic articles and associated 
    experiments following the DevOps model (@Sec:popper);
  * Popper-CLI: an experiment bootstrapping tool that makes 
    Popper-compliant experiments readily available to researchers; and
  * Two use cases detailing how to follow Popper in practice 
    (@Sec:cases).

In this work we demonstrate the benefits of following the Popper 
convention: it brings order to personal research workflows and makes 
it practical for others to re-execute experiments on multiple 
platforms with minimal effort, without having to speculate on what the 
original authors did to compile and configure the system; and shows 
how automated performance regression testing aids in maintaining the 
reproducibility integrity of experiments (@Sec:discussion discusses 
more extensively these points).

# Experimental Practices {#sec:common-practice}

In this section we examine common practices and identify desired 
features for a new experimental methodology.

## Common Practice

![A generic experimentation workflow typically followed by researchers 
in projects with a computational component. Some of the reasons to 
iterate (backwards-going arrows) are: fixing a bug in the code of a 
system, changing a parameter of an experiment or running the same 
experiment on a new workload or compute platform. Although not usually 
done, in some cases researchers keep a chronological record on how 
experiments evolve over time (the analogy of the lab notebook in 
experimental sciences). ](figures/exp_wflow.png){#fig:exp_workflow}

### Ad-hoc Personal Workflows

A typical practice is the use of custom bash scripts to automate some 
of the tasks of executing experiments and analyzing results. From the 
point of view of researchers, having an ad-hoc framework results in 
more efficient use of their time, or at least that's the belief. Since 
these are personalized scripts, they usually hard-code many of the 
parameters or paths to files in the local machine. Worst of all, a lot 
of the contextual information is in the mind of researchers. Without a 
list of guiding principles, going back to an experiment, _even for the 
original author on the same machine_, represents a time-consuming 
task.

### Sharing Source Code

Version-control systems give authors, reviewers and readers access to 
the same code base but the availability of source code does not 
guarantee reproducibility [@collberg_repeatability_2015]; code may not 
compile, and even it does, results may differ due to differences from 
other components in the software stack. While sharing source code is 
beneficial, it leaves readers with the daunting task of recompiling, 
reconfiguring, deploying and re-executing an experiment. Things like 
compilation flags, experiment parameters and results are fundamental 
contextual information for re-executing an experiment.

### Experiment Repositories

An alternative to sharing source code is experiment repositories 
[@stodden_researchcompendiaorg_2015 ; @roure_designing_2007]. These 
allow researchers to upload artifacts associated with a paper, such as 
input data sets. Similar to code repositories, one of the main 
problems is the lack of automation and structure for the artifacts. 
The availability of the artifacts does not guarantee the reproduction 
of results since a significant amount of manual work needs to be done 
after these have been downloaded. Additionally, large data 
dependencies cannot be uploaded since there is usually a limit on the 
artifact file size.

### Virtual Machines

A Virtual Machine (VM) can be used to partially address the 
limitations of only sharing source code. However, in the case of 
systems research where the performance is the subject of study, the 
overheads in terms of performance (the hypervisor "tax") and 
management (creating, storing and transferring) can be high and, in 
some cases, they cannot be accounted for easily [@clark_xen_2004]. In 
scenarios where OS-level virtualization is a viable alternative, it 
can be used instead of hardware-level virtualization 
[@jimenez_role_2015].

### Experiment Packing

Experiment packing entails tracing an experiment at runtime to capture 
all its dependencies and generating a package that can be shared with 
others [@chirigati_reprozip_2016 ; @davison_sumatra_2014]. Experiment 
packing is an automated way of creating a virtual machine or 
environment and thus suffers from the same limitations: external 
dependencies such as large datasets cannot be packaged; the experiment 
is a black-box without contextual information (e.g. history of 
modifications) that is hard to introspect, making difficult to build 
upon existing work; and packaging does not explicitly capture 
validation criteria.

### Data Analysis Ad-hoc Approaches

A common approach to analyze data is to capture CSV files and manually 
paste their contents into Excel or Google Spreadsheets. This manual 
manipulation and plotting lacks the ability to record important steps 
in the process of analyzing results, such as the series of steps that 
took to go from a CSV to a figure. While available (if the spreadsheet 
is public), it is not immediately clear what a researcher did.

### Eyeball Validation

Assuming the reader is able to recreate the environment of an 
experiment, validating the outcome requires domain-specific expertise 
in order to determine the differences between original and recreated 
environments that might be the root cause of any discrepancies in the 
results [@freire_computational_2012 ; @donoho_reproducible_2009]. 
Additionally, reproducing experimental results when the underlying 
hardware environment changes is challenging mainly due to the 
inability to predict the effects of such changes in the outcome of an 
experiment [@saavedra-barrera_cpu_1992]. In this case validation is 
typically done by "eyeballing" figures and the description of 
experiments in a paper, a subjective task, based entirely on the 
intuition and expertise of domain-scientists.

## Goals for a New Methodology

A diagram of a generic experimentation workflow is shown in 
@Fig:exp_workflow. The problem with current practices is that each of 
them partially cover the workflow. For example, sharing source code 
only covers the first task (source code); experiment packing only 
covers the second one (packaging); and so on. Based on this, we see 
the need for a new methodology that:

![The same workflow as in @Fig:exp_workflow viewed through a DevOps 
looking glass. The logos correspond to commonly used tools from the 
"DevOps toolkit". From left-to-right, top-to-bottom: git, mercurial, 
subversion (code); docker, vagrant, spack, nix (packaging); git-lfs, 
datapackages, artifactory, archiva (input data); bash, ansible, 
puppet, slurm (execution); git-lfs, datapackages, icinga, nagios 
(output data and runtime metrics); jupyter, paraview, travis, jenkins 
(analysis, visualization and continuous integration); restructured 
text, latex, asciidoctor and markdown (manuscript); gitlab, bitbucket 
and github (experiment changes).}
](figures/devops_approach.png){#fig:devops-approach}

  * Is reproducible without incurring any extra work for the 
    researcher. It should require the same or less effort than current 
    practices with the difference of doing things in a systematic way.
  * Improves the personal workflows of scientists by having a common 
    methodology that works for as many projects as possible and that 
    can be used as the basis of collaboration.
  * Captures the end-to-end workflow in a modern way, including the 
    history of changes that are made to an article throughout its 
    lifecycle.
  * Makes use of existing tools (don't reinvent the wheel!). The 
    DevOps toolkit is already comprehensive and easy to use.
  * Has the ability to handle large datasets.
  * Captures validation criteria in an explicit manner so that 
    subjective evaluation of results of a re-execution is minimized.
  * Results in experiments that are amenable to improvement and allows 
    easy collaboration, as well as making it easier to build upon 
    existing work.

# The DevOps Toolkit {#sec:toolkit}

We use the term DevOps [@httermann_devops_2012] to refer to a set of 
common practices that have the goal of expediting the delivery of a 
software project, allowing to iterate as fast as possible on 
improvements and new features, without undermining the quality of the 
software product. In our work, we make the case for achieving the same 
outcome for academic articles, which can be seen as taking the idea of 
an executable paper and implementing it with a DevOps approach.

In this section we review and highlight salient features of the DevOps 
toolkit that makes it amenable to organize all artifacts associated 
with an academic article. To guide our discussion, we refer to the 
generic experimentation workflow viewed through a DevOps looking glass 
shown in @Fig:devops-approach. In @Sec:popper we analyze more closely 
the composability of these tools and describe general guidelines (the 
convention) on how to structure projects that make use of the DevOps 
toolkit

## Version Control

Traditionally the content managed in a version-control system (VCS) is 
the project's source code; for an academic article the equivalent is 
the article's content: article text, experiments (code and data) and 
figures. The idea of keeping an article's source in a VCS is not new 
and in fact many people follow this practice [@dolfi_model_2014]. 
However, this only considers automating the generation of the article 
in its final format (usually PDF). While this is useful, here we make 
the distinction between changing the prose of the paper, changing the 
parameters of the experiment (both its components and its 
configuration), as well as storing the experiment results.

Ideally, one would like the entire end-to-end pipeline for all the 
experiments contained in an article to be managed by a version control 
system. With the advent of cloud-computing, this is possible for most 
research articles[^difficult-platforms]. One of the mantras of the 
DevOps movement [@wiggins_twelvefactor_2011] is to make 
"infrastructure as code". In a sense, having all the article's 
dependencies in the same repository is analogous to how large cloud 
companies maintain monolithic repositories to manage their internal 
infrastructure [@tang_holistic_2015 ; @metz_google_2015] but at a 
lower scale.

[^difficult-platforms]: For large-scale experiments or those that run 
on specialized platforms, re-executing an experiment might be 
difficult. However, this does not exclude such research projects from 
being able to keep the article's associated assets under version 
control.

**Tools and services**: Git, Svn and Mercurial are popular VCS tools. 
GitHub and BitBucket are web-based Git repository hosting services. 
They offer all of the distributed revision control and source code 
management (SCM) functionality of Git as well as adding their own 
features. They give new users the ability to look at the entire 
history of the project and its artifacts.

## Package Management

Availability of code does not guarantee reproducibility of results 
[@collberg_repeatability_2015]. The second main component in the 
experimentation pipeline is the packaging of applications so that 
users don't have to do it themselves. Software containers (e.g. 
Docker, OpenVZ or FreeBSD's jails) complement package managers by 
packaging all the dependencies of an application in an entire file 
system snapshot that can be deployed in systems "as is" without having 
to worry about problems such as package dependencies or specific OS 
versions. From the point of view of an academic article, these tools 
can be leveraged to package the dependencies of an experiment. 
Software containers like Docker have the great potential for being of 
great use in computational sciences [@boettiger_introduction_2014].

**Tools and services**: [Docker](http://docker.com) automates the 
deployment of applications inside software containers by providing an 
additional layer of abstraction and automation of 
operating-system-level virtualization on Linux. Alternatives to Docker 
are modern package managers such as Nix or Spack, or even virtual 
machines.

## Multi-node Orchestration

Experiments that require a set of machines to be orchestrated can make 
use of a tool that automatically manages binaries, updates packages 
across machines and drives the end-to-end execution of the experiment. 
Traditionally, this has been done with an ad-hoc bash script but for 
experiments that are continually tested there needs to be an automated 
solution.

**Tools and services**: Ansible is a configuration management utility 
for configuring and managing computers, as well as deploying and 
orchestrating multi-node applications. Similar tools include Puppet, 
Chef, Salt, among others.

## Bare-metal-as-a-Service

For experiments that are sensitive to the inherent variability 
associated to executing on consolidated infrastructures (e.g. Amazon's 
EC2), bare-metal as a service is an alternative.

**Tools and services**: Cloudlab [@ricci_introducing_2014], Chameleon 
and PRObE are NSF-sponsored infrastructures for research on cloud 
computing that allows users to easily provision bare-metal machines to 
execute multi-node experiments. Some cloud service providers such as 
Amazon allow users to deploy applications on bare-metal instances.

## Dataset Management

Some experiments involve the processing of large input, intermediary 
or output datasets. While possible, traditional version control tools 
such as Git were not designed to store large binary files. A proper 
artifact repository client or dataset management tool can take care of 
handling data dependencies.

**Tools and services**: Examples are Apache Archiva, Git-LFS, 
Datapackages or Artifactory.

## Data Analysis and Visualization

Once an experiment runs, the next task is to analyze and visualize 
results.

**Tools and services**: Jupyter notebooks run on a web-based 
application. It facilitates the sharing of documents containing live 
code (in Julia, Python or R), equations, visualizations and 
explanatory text. Other domain-specific visualization tools can also 
fit into this category. Binder is an online service that allows one to 
turn a GitHub repository into a collection of interactive Jupyter 
notebooks so that readers don't need to deploy web servers themselves. 
Alternatives to Jupyter are Gnuplot, Zeppelin and Beaker. Other 
scientific visualization such as Paraview tools can also fit in this 
category.

## Performance Monitoring

Prior to and during the execution of an experiment, capturing 
performance metrics can be beneficial. In the case of systems research 
articles, where performance is the main subject of study, capturing 
performance metrics is fundamental. Instead of creating ad-hoc tools 
to achieve this we can benefit by adopting and extending existing 
tools. At the end of the execution, the captured data can be analyzed 
and many of the graphs included in the article can come directly from 
running analysis scripts on top of this data.

**Tools and services**: Many mature monitoring tools exist such as 
Nagios, Ganglia, StatD, CollectD, among many others. For measuring 
single-machine baseline performance, tools like Conceptual (network), 
stress-ng (CPU, memory, file system) and many others exist.

## Continuous Integration

Continuous Integration (CI) is a development practice that requires 
developers to integrate code into a shared repository frequently with 
the purpose of catching errors as early as possible. The experiments 
associated with an article can also benefit from CI. If an 
experiment's findings can be codified in the form of a unit test, this 
can be verified on every change to the article's repository.

**Tools and services**: Travis CI is an open-source, hosted, 
distributed continuous integration service used to build and test 
software projects hosted at GitHub. Alternatives to Travis CI are 
CircleCI, CodeShip. Other on-premises solutions exist such as Jenkins.

## Automated Performance Regression Testing

Open source projects such as the Linux kernel go through rigorous 
performance testing to ensure that newer versions don't introduce any 
problems. Performance regression testing is usually an ad-hoc activity 
but can be automated using high-level languages [@jimenez_aver_2016] 
or statistical techniques [@nguyen_automated_2012].

**Tools and services**: Aver [@jimenez_aver_2016] is an example of a 
language and validation tool that allows authors to express and 
corroborate statements about the runtime metrics gathered of an 
experiment.

# The Popper Convention: A DevOps Approach to Producing Academic Papers {#sec:popper}

The goal for _Popper_ is to give researchers a common framework to 
reason, in a systematic way, about how to structure all the 
dependencies and generated artifacts associated with an experiment. In 
short, the convention can be thought of four high-level steps that 
outline how to implement a scientific exploration in a way that makes 
it easier to reproduce:

 1. Pick a DevOps tool for each stage of the scientific 
    experimentation workflow.
 2. Put all associated scripts (experiment and manuscript) in version 
    control, in order to provide a self-contained repository.
 3. Document changes as experiment evolves, in the form of version 
    control commits.

This convention provides the following unique features:

 1. Provides a methodology (or experiment protocol) for generating 
    self-contained experiments.
 2. Makes it easier for researchers to explicitly specify validation 
    criteria.
 3. Abstracts domain-specific experimentation workflows and 
    toolchains.
 4. Provides reusable experiment templates that provide curated 
    experiments commonly used by a research community.

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

## Self-containment

We say that an experiment is Popper-compliant (or that it has been 
"Popperized") if all of the following is available, either directly or 
by reference, in one single source-code repository: experiment code, 
experiment orchestration code, reference to data dependencies, 
parametrization of experiment, validation criteria and results. In 
other words, a Popper repository contains all the dependencies for an 
article, including its manuscript. The structure of a Popper repo is 
simple, there are `paper/` and `experiments/` folders, and every 
experiment has a `datasets/` folder in it.

An example paper project is shown in @Lst:dir. A paper repository is 
composed primarily of the article text and experiment orchestration 
logic. The actual code that gets executed by an experiment is not part 
of the repository. This, as well as any large datasets that are used 
as input to an experiment, reside in their own repositories and are 
stored in the experiment folder of paper repository as references.

With all these artifacts available, the reader can easily deploy an 
experiment
or rebuild the article's PDF that might include new results.
@Fig:review-workflow shows our vision for the reader/reviewer workflow when
reading a Popper for a Popperized article. The diagram uses tools we use in the
use-case in Section 5.2, like Ansible and Docker, but as mentioned earlier,
these can be swapped by equivalent tools. Using this workflow, the writer is
completely transparent and the article consumer is free to explore results,
re-run experiments, and contradict assetions in the paper. 

A paper is written in any desired markup language. In the above listing we use
LATeX as an example (`paper.tex` file). There is a `build.sh` command that
generates the output format (e.g. `PDF`). For the experiment execution logic,
each experiment folder contains the necessary information such as setup, output
post-processing (data analysis) and scripts for generating an image from the
results. The execution of the experiment will produce output that is either
consumed by a post-processing script, or directly by the scripts that generate
an image.

![A sample workflow a paper reviewer or reader would use to read a 
Popperized article. (1) The PDF, Jupyter or Binder are used to 
visualize and interact with the results post-mortem on the reader's 
local machine. (2) If needed the reader has the option of looking at 
the code and clone it locally (GitHub); for single-node experiments, 
they can be deployed locally too (Docker). (3) For multi-node 
experiments, Ansible can then be used to deploy the experiment on a 
public or private cloud (NSF's CloudLab in this case). (4) Lastly, 
experiments producing large data sets can make use of cloud storage. 
Popper is tool agnostic, so GitHub can be replaced with GitLab, 
Ansible with Puppet, Docker with VMs, etc.
](figures/wflow.png){#fig:review-workflow}

The output can be in any format (CSVs, HDF, NetCDF, etc.), as long as 
it is versioned and referenced. An important component of the 
experiment logic is that it should assert the original assumptions 
made about the environment (a `setup.yml` file in the example), for 
example, the operating system version (if the experiment assumes one). 
Also, it is important to parametrize the experiment explicitly (e.g. 
`vars.yml`), so that readers can quickly get an idea of what is the 
parameter space of the experiment and what they can modify in order to 
obtain different results. One common practice we follow is to place in 
the caption of every figure a `[source]` link that points to the URL 
of the corresponding post-processing script in the version control web 
interface (e.g. GitHub).

## Automated Validation

Validation of experiments can be classified in two categories. In the 
first one, the integrity of the experimentation logic is checked using 
existing continuous-integration (CI) services such as TravisCI, which 
expects a `.travis.yml` file in the root folder. This file contains a 
specification that consists of a list of tests that get executed every 
time a new commit is added to the repository. These types of checks 
can verify that the paper is always in a state that can be built 
(generate the PDF correctly); that the syntax of orchestration files 
is correct so that if changes occur, e.g., addition of a new variable, 
it can be executed without any issues; or that the post-processing 
routines can be executed without problems.

The second category of validations is related to the integrity of the 
experimental results. These domain-specific tests ensure that the 
claims made in the paper are valid for every re-execution of the 
experiment, analogous to performance regression tests done in software 
projects that can be implemented using the same class of tools. 
Alternatively, claims can also be corroborated as part of the analysis 
code. When experiments are not sensitive to the effects of virtualized 
platforms, these assertions can be executed on public/free CI 
platforms (e.g. TravisCI runs tests in VMs). However, when results are 
sensitive to the underlying hardware, it is preferable to leave this 
out of the CI pipeline and make them part of the post-processing 
routines of the experiment. In the example above, an `assertions.aver` 
file contains validations in the Aver [@jimenez_aver_2016] language 
that check the integrity of runtime performance metrics that claims 
make reference to. Examples of these type of assertions are: "the 
runtime of our algorithm is 10x better than the baseline when the 
level of parallelism exceeds 4 concurrent threads"; or "for dataset A, 
our model predicts the outcome with an error of 95%". More concrete 
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
monitoring tools such as Nagios can capture raw system-level 
performance; and existing frameworks such as baseliner are designed to 
obtain baseline profiles that are associated to experimental results. 
All these different sources of baseline performance characteristics 
can serve as a "fingerprint" of the underlying platform and can be 
given to tools such as Aver so that assertions about the environment 
are executed before an experiment runs, as a way of sanitizing the 
execution.

## Toolchain Agnosticism

We designed Popper as a general convention, applicable to a wide 
variety of environments, from cloud to high-performance computing 
(HPC). In general, Popper can be applied in any scenario where a 
component (data, code, infrastructure, hardware, etc.) can be 
referenced by an identifier, and where there is an underlying tool 
that consumes these identifiers so that they can be acted upon 
(install, run, store, visualize, etc.). The core idea behind Popper is 
to borrow from the DevOps movement [@wiggins_twelvefactor_2011] the 
idea of treating every component as an immutable piece of information 
and provide references to scripts and components for the creation, 
execution and validation of experiments (in a systematic way) rather 
than leaving to the reader the daunting task of inferring how binaries 
and experiments were generated or configured.

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

We say that a tool is Popper-compliant if it has the following two 
basic properties:

 1. Assets can be be associated to unique identifiers. Code, packages, 
    configurations, data, results, etc. can all be referenced and 
    uniquely identified.
 2. The tool is scriptable (e.g. can be invoked from the command line) 
    and can act upon given asset IDs.

In @Sec:toolkit we provided a list of tools for every category of the 
generic experimentation workflow (@Fig:exp_workflow) that comply with 
the two properties given above.

In general, tools that are hard to script e.g. because they don't 
provide a command-line interface (can only interact via GUI) or they 
only have a programmatic API for a non-interpreted language, are 
beyond the scope of Popper.

## Experiment Templates

Researchers that decide to follow Popper are faced with a steep 
learning curve, especially if they have only used a couple of tools 
from the DevOps toolkit. To lower the entry barrier, we have developed 
a command line interface (CLI) tool[^link:cli] to help bootstrap a 
paper repository that follows the Popper convention.

As part of our efforts, we maintain a list of experiment templates 
that have been "Popperized". These are end-to-end experiments that use 
a particular toolchain and for which execution, production of results 
and generation of figures has been implemented (see @Sec:cases for 
examples; each use case is available as an experiment in the templates 
repository). The CLI tool can list and show information about 
available experiments. Assuming a git repository has been initialized, 
the tool allows to add experiments to the repository (@Lst:poppercli). 
Templates and CLI can be found at <http://falsifiable.us>.

# Use Cases {#sec:cases}

We now show use cases for two different toolchains that illustrate how 
Popper is tool-agnostic. Due to space constraints we have to reduce 
the number of use cases and experiments for each. We refer the reader 
to this paper's Popper repository 
<https://github.com/systemslab/popper-paper> for more detailed 
information about the experimental setup as well as more use cases and 
comprehensive results.

## Torpor: Quantifying Cross-platform Performance Variability {#sec:torpor}

![\[[source](https://github.com/systemslab/popper-paper/tree/asplos17/experiments/torpor)\] 
Variability profile of a set of CPU-bound benchmarks. Each data point 
in the histogram corresponds to the speedup of a stress-ng 
microbenchmark that a node in CloudLab has with respect to one of our 
machines in our lab, a 10 year old Xeon. For example, the 
architectural improvements of the newer machine cause 7 stressors to 
have a speedup within the `(2.2, 2.3]` range over the base machine.
](experiments/torpor/variability_profile.png){#fig:torpor-variability}

Reproducing systems experiments is sometimes challenging due to their 
sensitivity to the underlying hardware and low-level software stack 
(firmware and OS). In this use case we exemplify how an experiment 
that is potentially sensitive to a customized version of the OS can be 
"Popperized", e.g. because it needs particular features of a custom 
kernel or specific drivers. Torpor [@jimenez_characterizing_2016] is a 
workload- and architecture-independent technique for characterizing 
the performance of a computing platform. Given that the authors of the 
Torpor paper followed the Popper convention, thus we just have taken 
the experiment for this use case "as is" and include it in the Popper 
repository of this article.

In short, Torpor works by executing a battery of micro-benchmarks and 
using these as the performance profile of a system. Given two profiles 
of two distinct platforms A and B, Torpor generates a variability 
range of B with respect to A. These variability profiles can then be 
used to predict the variability of any application running on B, that 
originally ran A. The goal is to predict as well as recreate 
performance of applications that run on newer (and faster) platforms 
using OS-level virtualization.

We take the experiment from the original paper that quantifies the 
variability of a list of machines with respect to a 10 year old system 
[@jimenez_characterizing_2016] (Figure 2 of the original article). Due 
to space constraints, we only show the variability profile for one 
machine but results for all the other machines are available in this 
paper's repository. Since we are interested in "pinning" a particular 
kernel version, a natural option is to use a virtual machine to 
package the experiment. Vagrant is a higher-level wrapper around 
virtualization software that provides the framework and configuration 
format (Ruby language scripts) to create and manage complete portable 
development environments.

The experiment folder contains all necessary files to easily invoke it 
and generate figures. A bash `run.sh` script installs Vagrant if it is 
not present; downloads the VM or builds it if links are broken; and 
lastly executes the experiment. Once the VM runs, the results are 
placed in the folder where the experiment was invoked (CSV files). The 
analysis is done in Gnuplot, which in this case runs on the host but 
could be packaged in a Docker container or another VM. The result of 
executing the Gnuplot script generates @Fig:torpor-variability. As 
mentioned before, the goal of Popper is to provide self-contained 
experiments with minimal 3rd party and effort requirements.

## GassyFS: Scalability of an In-memory File System {#sec:gassyfs}

This use case illustrates how multi-node experiments can be easily 
ported between multiple platforms. It also exemplifies how the 
validation criteria of an experiment can be made explicit and be 
automatically checked with currently available tools.

GassyFS [@watkins_gassyfs_2016] is a new prototype file system system 
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
additional features. To mount GassyFS, we use FUSE, which can be given 
more than 30 different options, many of them taking multiple values.

![\[[source](https://github.com/systemslab/popper-paper/tree/asplos17/experiments/gassyfs/visualize.ipynb)\] 
Scalability of GassyFS as the number of nodes in the GASNet cluster 
increases. The workload in question compiles Git.
](experiments/gassyfs/git-multinode.png){#fig:gassyfs-git}

In @Fig:gassyfs-git we show one of multiple experiments that evaluate 
the performance of GassyFS. We note that while the performance numbers 
obtained are relevant, they are not our main focus. Instead, we put 
more emphasis on the goals of the experiments, how we can reproduce 
results on multiple environments with minimal effort, and how we can 
ensure the validity of the results. Re-executing this experiment on a 
new platform only requires to have host nodes to run Docker and to 
modify the list of hosts given to Ansible (a list of IP addresses), 
everything else, including the validation of results, is fully 
automated.

In this experiment we aim to evaluate the scalability of GassyFS, i.e. 
how it performs when we increase the number of nodes in the underlying 
GASNet-backed FUSE mount. @Fig:gassyfs-git shows the results of 
compiling Git on GassyFS. We observe that once the cluster gets to 2 
nodes, performance degrades sublinearly with the number of nodes. This 
is expected for workloads such as the one in question. The Aver 
assertion in @Lst:aver-assertion is used to check the integrity of 
this result.

```{#lst:aver-assertion .sql caption="Assertion to check scalability behavior."}
  when
    workload=* and machine=*
  expect
    sublinear(nodes,time)
```

The above expresses our expectation of GassyFS performing sublinearly 
with respect to the number of nodes. After the experiment runs, Aver 
is invoked to test the above statement against the experiment results 
obtained.

## Benefits and Limitations

The use cases in this section illustrate how easier it is to pull an 
already Popperized experiment. While it might seem like 
a burden, at the beginning of an experimental exploration, following 
Popper quickly pays-off. Consider the common situation of going back 
to an experiment after a short amount of time and the struggle the 
represents having to remember what was done, or why things were done 
in a particular way. However, Popper is not perfect. Obvious issues 
such as the lack of resources, either because of the use of special 
hardware or due to the large-scale nature of an experiment, have to be 
resolved before a Popperized experiment is re-executed. Nevertheless, 
having access to the original experiment and all associated artifacts 
is extremely valuable. Additionally, in some cases, the choice one 
selects to package an experiment might affect its reproducibility such 
as in cases where VMs introduce ineligible overheads.

# The Case for Popper {#sec:discussion}

## We did well for 50 years. Why fix it?

Shared infrastructures "in the cloud" are becoming the norm and enable 
new kinds of sharing, such as experiments, that were not practical 
before. Thus, the opportunity of these services goes beyond just 
economies of scale: by using conventions and tools to enable 
reproducibility, we can dramatically increase the value of scientific 
experiments for education and for research. The Popper Convention 
makes not only the result of a systems experiment available but the 
entire experiment and allows researchers to study and reuse all 
aspects of it, making it practical to "stand on the shoulders of 
giants" by building upon the work of the community to improve the 
state-of-the-art without having to start from scratch every time.

## The power of "crystallization points."

Docker images, Ansible playbooks, CI unit tests, Git repositories, and 
Jupyter notebooks are all examples of artifacts around which 
broad-based efforts can be organized. Crystallization points are 
pieces of technology, and are intended to be easily shareable, have 
the ability to grow and improve over time, and ensure buy-in from 
researchers and students. Examples of very successful crystallization 
points are the Linux kernel, Wikipedia, and the Apache Project. 
Crystallization points encode community knowledge and are therefore 
useful for leveraging past research efforts for ongoing research as 
well as education and training. They help people to form abstractions 
and common understanding that enables them to more effectively 
communicate reproducible science. By having popular tools such as 
Docker/Ansible as a lingua franca for researchers, and Popper to guide 
them in how to structure their paper repositories, we can expedite 
collaboration and at the same time benefit from all the new advances 
done in the DevOps world.

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

Current practices in the systems research community don't include 
either controlled or statistical reproducibility experiments. Instead, 
people run several executions (usually 10) on the same machine and 
report averages. Our convention can be used to either of these two 
approaches.

## Perfect is the enemy of good

No matter how hard we try, there will always be something that goes
wrong. The context of systems experiments is often very complex and
that complexity is likely to increase in the future. Perfect
repeatability will be very difficult to achieve. Recent empirical
studies in computer systems [@hoefler_scientific_2015 ;
@collberg_repeatability_2015] have brought attention to the main
issues that permeate the current practice of our research communities,
where scenarios like the lack of information on how a particular
package was compiled, or which statistical functions were used make it
difficult to reproduce or even interpret results. We don't aim at
perfect repeatability but to minimize issues that we currently face
and to have a common language that can be used while collaborating to
fix all these type of reproducibility issues.

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
experiment and leveraging shared infrastructure. By providing 
performance profiles alongside experimental results, this allows to 
preserve the performance characteristics of the underlying hardware 
that an experiment executed on and facilitates the interpretation of 
results in the future.

## DevOps Skills Are Highly Valued by Industry

While the learning curve for the DevOps toolkit is steep, having these 
as part of the skillset of students or researchers-in-training can 
only improve their curriculum. Since industry and many 
industrial/national laboratories have embraced a DevOps approach (or 
are in the process of embracing), making use of these tools improves 
their prospects of future employment. In other words, these are skills 
that will hardly represent wasted time investments, on the contrary, 
this might be motivation enough for students to learn at least one 
tool from each of the stages of the DevOps pipeline.

## Popper Complements Existing Efforts

There have been efforts to address the issues in subdomains of the 
systems research community. We believe Popper complements many of 
these since it encourages a practice (i.e. to follow a protocol) that 
applies on top of tools that researchers already know rather than 
requiring scientists to learn a whole new suite of tools. Some 
examples of community efforts and projects that Popper complements 
well are the following.

  * Ctuning Foundation's Extended Artifact Description Guide 
    [@ctuningfoundation_extended_2016] is a set of high-level 
    guidelines for authors on how to prepare an "Artifact Evaluation" 
    appendix for academic articles. Conferences such as 
    Supercomputing, TRUST@PLDI, CGO/PPoP and others are currently 
    making use of it for their reproducibility initiatives. Popper 
    implements a similar pipeline as the one described in the Artifact 
    Description Guide. A Popper repository could even be used instead 
    of an "Artifact Evaluation" appendix.
  * Elsevier's 2011 Executable Paper Challenge 
    [@elsevier_executable_2011] gave the first prize to the Collage 
    Authoring Environment [@nowakowski_collage_2011]. Popper is an 
    alternative that makes use of the DevOps toolkit, allowing 
    researchers to keep using their tools but to structure their 
    explorations in a systematic way.
  * Proxy applications (Mini-apps) in HPC [@dosanjh_achieving_2011] 
    can be accompanied with a Popper repository to make it easier to 
    validate performance results and facilitate the execution of these 
    on different platforms.
  * The Open Encyclopedia of Parallel Algorithmic Features 
    [@voevodin_algowiki_2015]. We envision having a Popper repository 
    for the encyclopedia to make it easier for readers to reuse the 
    algorithms and their insights. Since MediaWiki is already 
    versioned, the wiki and the experiments could reside on the same 
    repository, with the `README` of the experiment being the wiki 
    article, linking to figures that are obtained directly from the 
    algorithm execution output.
  * The Journal of Information Systems has recently adopted a new 
    publication model that incentivizes reproducibility by inviting 
    original authors to collaborate with independent reviewers and 
    publish a subsequent paper on whether they could reproduce the 
    original work [@chirigati_collaborative_2016]. By following Popper 
    authors can potentially reduce the amount of work that these 
    subsequent publications entail.

# Bibliography

<!-- hanged biblio -->

\noindent
\vspace{-2em}
\setlength{\parindent}{-0.26in}
\setlength{\leftskip}{0.2in}
\setlength{\parskip}{8pt}
