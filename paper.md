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

<!-- From 250-1000 words -->

<!-- A summary describing the high-level functionality and purpose of
the software for a diverse, non-specialist audience. -->

<!-- A Statement of need section that clearly illustrates the research
purpose of the software and places it in the context of related
work. -->

<!-- A list of key references, including to other software addressing
related needs. Note that the references should include full names of
venues, e.g., journals and conferences, not abbreviations only
understood in the context of a specific discipline. -->

<!-- Mention (if applicable) a representative set of past or ongoing
research projects using the software and recent scholarly publications
enabled by it. -->

<!-- Acknowledgement of any financial support. -->

# Summary

State-of-the-art programming approaches generally have a strict
division between intra-node shared memory parallelism and inter-node
MPI communication.  Tasking with dependencies offers a clean,
dependable abstraction for a wide range of hardware and situations
within a node, but research on task offloading between nodes is still
relatively immature.

In the paper we present
[OmpSs-2@Clusters](https://github.com/bsc-pm/ompss-2-cluster-releases)
runtime system and programming model.  Which is the distributed memory
evolution of the [OmpSs](https://pm.bsc.es/ftp/ompss-2/doc/spec/) task
based programming model and the
[nanos6](https://github.com/bsc-pm/nanos6) runtime.  This artifact
[@Aguilar2022Artifact] includes how to reproduce the scalability
results in the main paper with the same title.  The whole artifact
includes an **Overview** document with a detailed description of the
actions to perform and some bash script to automatize the basic steps,
process the results and construct the graphs.

# Statement of need

Reproducibility is a fundamental step in scientific development and
research. Modern systems in High Performance Computing are more
complex either in software and hardware making data reproduction
cumbersome and very time consuming.


# Acknowledgements

This research has received funding from the European Union’s Horizon
2020/EuroHPC research and innovation programme under grant agreement
No 955606 (DEEP-SEA) and 754337 (EuroEXA). It is supported by the
Spanish State Research Agency - Ministry of Science and Innovation
(contract PID2019-107255GB and Ramon y Cajal fellowship
RYC2018-025628-I) and by the Generalitat de Catalunya (2017-SGR-1414).


# References
