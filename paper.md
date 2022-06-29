---
title: 'OmpSs-2@Cluster: Distributed memory execution of nested OpenMP-style tasks'
tags:
  - OmpSs-2
  - Task
  - Cluster
  - Programming Model
  - Runtime
  - Multi-threading
authors:
  - name: Jimmy Aguilar Mena
    orcid: 0000-0001-6802-2247
    corresponding: true
    affiliation: 1
  - name: Omar Shaaban
    orcid: 0000-0003-4410-5317
    equal-contrib: true
    affiliation: 1
  - name: Vicenc Beltran
    orcid: 0000-0002-3580-9630
    equal-contrib: true
    affiliation: 1
  - name: Paul Carpenter
    orcid: 0000-0002-9392-0521
    equal-contrib: true
    affiliation: 1
  - name: Eduard Ayguade
    orcid: 0000-0002-5146-103X
    equal-contrib: true
    affiliation: 1
  - name: Jesus Labarta Mancho
    orcid: 0000-0002-7489-4727
    equal-contrib: true
    affiliation: 1
affiliations:
  - name: Barcelona Supercomputing Center, Spain
    index: 1
date: 25 June 2022
bibliography: paper.bib
---

# Summary

This work presents the
[Nanos6@Cluster](https://github.com/bsc-pm/ompss-2-cluster-releases)
runtime system, which is the reference runtime system implementation
for the OmpSs-2@Cluster programming model [@Aguilar2022Europar].
OmpSs-2@Cluster is the flexible distributed memory variant of
[OmpSs](https://pm.bsc.es/ftp/ompss-2/doc/spec/), which supports
offloading of tasks among nodes. The program inherits task ordering
from the sequential version of the code and it uses a common address
space to avoid address translation and simplify the use of data
structures with pointers.

We also include four benchmarks for evaluation, together with the
scripts
[artifact.sh](https://github.com/Ergus/PaperOmpSs-ClustersArtifact/blob/master/artifact.sh)
and documentation
[Overview.pdf](https://github.com/Ergus/PaperOmpSs-ClustersArtifact/releases/download/v1.0/Overview.pdf)
needed to reproduce the results in the paper. As such, we hope to
enable future researchers to reproduce and evaluate our work, compare
alternative approaches with state-of-the-art and build on our work to
exploit the task offloading support for resilience, malleability, load
balancing [@Carpenter2022ICPP] and other purposes.

# Statement of need

State-of-the-art programming approaches generally have a strict
division between intra-node shared memory parallelism and inter-node
MPI communication.  Tasking with dependencies offers a clean,
dependable abstraction for a wide range of hardware and situations
within a node, but research to extend the model to encompass
parallelism among nodes is still relatively immature.

[OpenMP](https://www.openmp.org/specifications/) is the most popular
alternative for asynchronous task programming in Shared Memory
systems. Over the years OmpSs has influenced OpenMP with multiple
features as explained in [@OmpSsOpenMP]. Besides that, extending
applications among multiple nodes requires hybrid programming
techniques to mix OpenMP code with Message Passing Interface
[MPI](https://www.mpi-forum.org/) for communications. This usually
leads is complex code that requires extra effort to maintain and
optimize the different levels of parallelism.

This work presents
[Nanos6@Cluster](https://github.com/bsc-pm/ompss-2-cluster-releases),
which is the reference runtime system implementation for the
OmpSs-2@Cluster [@Aguilar2022Europar] programming model.
OmpSs-2@Cluster is the flexible distributed memory variant of
[OmpSs](https://pm.bsc.es/ftp/ompss-2/doc/spec/), which supports
offloading of tasks among nodes. The application inherits task
ordering from the sequential version of the code and it uses a common
address space to avoid address translation and simplify the use of
data structures with pointers.

Nanos6@Cluster has been under development since 2016, and it is a
derivative of [Nanos6](https://github.com/bsc-pm/nanos6), which has
been in development since 2015 as a successor for
[Nanos++](https://pm.bsc.es/nanox). It implements the complete
OmpSs-2@Cluster programming model and the runtime optimizations
described in the EuroPar publication [@Aguilar2022Europar].

We also include the [Mercurium](https://github.com/bsc-pm/mcxx)
source-to-source compiler, with extensions for OmpSs-2@Cluster and a
set of [benchmarks](https://github.com/Ergus/nanos-cluster-benchmarks)
with multiple implementations for four benchmarks: matvec, matmul,
jacobi and cholesky.

The whole artifact [@Aguilar2022Artifact] comprises steps and
instructions described in the
[Overview.pdf](https://github.com/Ergus/PaperOmpSs-ClustersArtifact/releases/download/v1.0/Overview.pdf)
document and implemented in the
[artifact.sh](https://github.com/Ergus/PaperOmpSs-ClustersArtifact/blob/master/artifact.sh)
bash script to simplify the user initial experience.  The fundamental
parts enable the user to:

1. Build and install
   [Nanos6-Cluster](https://github.com/bsc-pm/nanos6-cluster) and the
   [Mercurium](https://github.com/bsc-pm/mcxx) source-to-source
   compiler
2. Build the Nanos6 benchmarks suite
   [nanos6-cluster-benchmarks](https://github.com/Ergus/nanos-cluster-benchmarks)
   and the MPI benchmarks suite
   [MPI-benchmarks](https://github.com/Ergus/MPI_Benchmarks) to
   compare both implementations with a baseline.
3. Execute the benchmarks and reproduce the published results.
4. Process the output to construct the graphs automatically.

The provided [benchmarks
suite](https://github.com/Ergus/nanos-cluster-benchmarks) also
includes multiple variants of the benchmarks with different levels of
optimization, and it easily supports different external libraries,
compilers and debugging options.

The key references for this work are [@Aguilar2022Europar], as well as
[@Carpenter2022ICPP] for work on dynamic load balancing.

By releasing our work as open source, we wish to enable future
researchers to reproduce and evaluate our work, compare it with
alternative approaches, and build on our work to exploit
OmpSs-2@Cluster task offloading to improve support for resilience,
malleability, load balancing and other purposes.

# Acknowledgements

This research has received funding from the European Union’s Horizon
2020/EuroHPC research and innovation programme under grant agreement
No 955606 (DEEP-SEA) and 754337 (EuroEXA). It is supported by the
Spanish State Research Agency - Ministry of Science and Innovation
(contract PID2019-107255GB and Ramon y Cajal fellowship
RYC2018-025628-I) and by the Generalitat de Catalunya (2017-SGR-1414).


# References
