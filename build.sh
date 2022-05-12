#!/bin/bash

set -o xtrace
set -e

[ -z $@ ] && args="build exec process graph" || args="$@"

echo "# Starting OmpSs-2@Cluster installation."
export STARTDIR=${PWD}
rm -rf nanos6-cluster
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
rm -rf mcxx
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
rm -rf nanos-cluster-benchmarks
git clone --depth=1 https://github.com/Ergus/nanos-cluster-benchmarks
mkdir nanos-cluster-benchmarks/build
cd nanos-cluster-benchmarks/build
cmake --CMAKE_BUILD_TYPE=Release ..
make
export NANOS6_CONFIG=${PWD}/nanos6.toml

echo "# Start mpi-benchmarks build"
cd ${STARTDIR}
rm -rf MPI_Benchmarks
git clone --depth=1 --recursive https://github.com/Ergus/MPI_Benchmarks
mkdir MPI_Benchmarks/build
cd MPI_Benchmarks/build
cmake --CMAKE_BUILD_TYPE=Release ..
make

echo "# If you see this line installation succeeded!!"
echo "# Please to run the benchmarks remember to export the following variables:"
echo "# NANOS6_HOME=${NANOS6_HOME}"
echo "# NANOS6_CONFIG=${NANOS6_CONFIG}"
echo "# And your PATH must contain ${MERCURIUM_HOME}/bin in order to use the mercurium compiler"

echo "Start running a benchmark subset."
cd ${STARTDIR}/nanos-cluster-benchmarks/build/matmul_matvec_ompss2

cp ${STARTDIR}/MPI_Benchmarks/build/matmul_matvec_mpi/matvec_parallelfor_mpi .
./interactive_dim.sh -N 1,2 -R 10 -D 65536 -B 256 -I 1 \
	matvec_strong_flat_task_node_blas_ompss2 \
	matvec_weak_fetchall_task_node_blas_ompss2 \
	matvec_parallelfor_mpi | tee ${STARTDIR}/output_matvec.txt

cp ${STARTDIR}/MPI_Benchmarks/build/matmul_matvec_mpi/matmul_parallelfor_mpi .
./interactive_dim.sh -N 1,2 -R 10 -D 16384 -B 16 -I 1 \
	matmul_strong_nested_task_node_blas_ompss2 \
	matmul_weak_fetchall_task_node_blas_ompss2 \
	matmul_parallelfor_mpi | tee ${STARTDIR}/output_matmul.txt

cd ${STARTDIR}/nanos-cluster-benchmarks/build/jacobi_ompss2
cp ${STARTDIR}/MPI_Benchmarks/build/jacobi_mpi/jacobi_parallelfor_mpi .
./interactive_dim.sh -N 1,2 -R 10 -D 65536 -B 256 -I 1 \
	jacobi_task_fetchall_blas_ompss2 \
	jacobi_taskfor_blas_ompss2 \
	jacobi_parallelfor_mpi | tee ${STARTDIR}/output_jacobi.txt

cd ${STARTDIR}/nanos-cluster-benchmarks/build/cholesky_fare_ompss2
cp ${STARTDIR}/MPI_Benchmarks/build/cholesky_mpi/cholesky_omp_mpi .
./interactive_dim.sh -N 1,2 -R 10 -D 65536 -B 512 -I 1 \
	cholesky_fare_strong_ompss2 \
	cholesky_fare_taskfor_ompss2 \
	cholesky_omp_mpi | tee ${STARTDIR}/output_cholesky.txt

echo "# If you see this line all the benchmarks executed properly.!!"
