#!/usr/bin/bash

set -o xtrace
set -e

echo "# Starting OmpSs-2@Cluster installation."

export STARTDIR=${PWD}
git clone --depth 1 https://github.com/bsc-pm/nanos6-cluster
cd nanos6-cluster
sed -i '12i#include <cstddef>' src/memory/AddressSpace.hpp # Some compilers need this
autoreconf -vif
export NANOS6_HOME=${STARTDIR}/nanos6-cluster-install
./configure --enable-cluster --enable-execution-workflow --prefix=${NANOS6_HOME} \
            --disable-lint-instrumentation --disable-ctf-instrumentation \
            --disable-graph-instrumentation --disable-stats-instrumentation \
            --disable-extrae-instrumentation --disable-verbose-instrumentation
make -j install

echo "# Starting Mercurium installation."

cd ${STARTDIR}
git clone --depth 1 https://github.com/bsc-pm/mcxx
cd mcxx
autoreconf -vif
export MERCURIUM_HOME=${STARTDIR}/mcxx-install
./configure --prefix=${MERCURIUM_HOME} \
            --with-nanos6=${NANOS6_HOME} \
            --enable-ompss-2
make -j install
export PATH=${MERCURIUM_HOME}/bin:${PATH}

echo "# Start nanos-cluster-benchmarks build"

cd ${STARTDIR}
git clone --depth=1 https://github.com/Ergus/nanos-cluster-benchmarks
mkdir nanos-cluster-benchmarks/build
cd nanos-cluster-benchmarks/build
cmake --BUILD_TYPE=Release ..
make
export NANOS6_CONFIG=${PWD}/nanos6.toml

echo "# Start mpi-benchmarks build"

cd ${STARTDIR}
git clone --depth=1 --recursive https://github.com/Ergus/MPI_Benchmarks
mkdir MPI_Benchmarks/build
cd MPI_Benchmarks/build
cmake --BUILD_TYPE=Release ..
make

echo "# If you see this line installation succeeded"
echo "# Please to run the benchmarks remember to export the following variables:"
echo "# NANOS6_HOME=${NANOS6_HOME}"
echo "# NANOS6_CONFIG=${NANOS6_CONFIG}"
echo "# And your PATH must contain ${MERCURIUM_HOME}/bin in order to use the mercurium compiler"
