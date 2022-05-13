#!/bin/bash

set -x
set -e

# Redirect all the outputs to the logfile
exec &> >(tee -a "nanos6_automatic_build.log")

echo "# Get OmpSs-2@Cluster release."
git clone --branch 2022.02 https://github.com/bsc-pm/ompss-2-cluster-releases
cd ompss-2-cluster-releases
export STARTDIR=${PWD}
git submodule init
git submodule update --depth 1

cd ${STARTDIR}/nanos6-cluster && echo "# Starting OmpSs-2@Cluster installation."
sed -i '12i#include <cstddef>' src/memory/AddressSpace.hpp # Some compilers need this
autoreconf -vif
export NANOS6_HOME=${STARTDIR}/nanos6-cluster-install
./configure --enable-cluster --enable-execution-workflow --prefix=${NANOS6_HOME} \
            --disable-lint-instrumentation --disable-ctf-instrumentation \
            --disable-graph-instrumentation --disable-stats-instrumentation \
            --disable-extrae-instrumentation --disable-verbose-instrumentation
make install

cd ${STARTDIR}/mcxx && echo "# Starting Mercurium installation." && 
autoreconf -vif
export MERCURIUM_HOME=${STARTDIR}/mcxx-install
./configure --prefix=${MERCURIUM_HOME} \
            --with-nanos6=${NANOS6_HOME} \
            --enable-ompss-2
make install
export PATH=${MERCURIUM_HOME}/bin:${PATH}

echo "# Start nanos-cluster-benchmarks build" && cd ${STARTDIR}
git clone --depth=1  --branch=europar https://github.com/Ergus/nanos-cluster-benchmarks
mkdir nanos-cluster-benchmarks/build
cd nanos-cluster-benchmarks/build
cmake -DCMAKE_BUILD_TYPE=Release ..
make # Don't add -j here
export NANOS6_CONFIG=${STARTDIR}/nanos6.toml

echo "# Start mpi-benchmarks build" && cd ${STARTDIR}
git clone --depth=1 --branch=europar --recursive https://github.com/Ergus/MPI_Benchmarks
mkdir MPI_Benchmarks/build
cd MPI_Benchmarks/build
cmake -DCMAKE_BUILD_TYPE=Release ..
make # Don't add -j here

echo "# If you see this line installation succeeded!!"
echo "# Please to run the benchmarks remember to export the following variables:"
echo "# NANOS6_HOME=${NANOS6_HOME}"
echo "# NANOS6_CONFIG=${NANOS6_CONFIG}"
echo "# And your PATH must contain ${MERCURIUM_HOME}/bin in order to use the mercurium compiler"

echo "Start running a benchmark subset." && cd ${STARTDIR}
cd nanos-cluster-benchmarks/build/matmul_matvec_ompss2

cp ${STARTDIR}/MPI_Benchmarks/build/matmul_matvec_mpi/matvec_parallelfor_blas_mpi .
./interactive_dim.sh -N 1,2 -R 10 -D 65536 -B 256 -I 5 \
	matvec_strong_flat_task_node_blas_ompss2 \
	matvec_weak_fetchall_task_node_blas_ompss2 \
	matvec_parallelfor_blas_mpi | tee ${STARTDIR}/output_matvec.txt

cp ${STARTDIR}/MPI_Benchmarks/build/matmul_matvec_mpi/matmul_parallelfor_blas_mpi .
./interactive_dim.sh -N 1,2 -R 10 -D 16384 -B 16 -I 5 \
	matmul_strong_nested_task_node_blas_ompss2 \
	matmul_weak_fetchall_task_node_blas_ompss2 \
	matmul_parallelfor_blas_mpi | tee ${STARTDIR}/output_matmul.txt

cd ${STARTDIR}/nanos-cluster-benchmarks/build/jacobi_ompss2
cp ${STARTDIR}/MPI_Benchmarks/build/jacobi_mpi/jacobi_parallelfor_nop2p_blas_mpi .
./interactive_dim.sh -N 1,2 -R 10 -D 65536 -B 256 -I 5 \
	jacobi_task_fetchall_blas_ompss2 \
	jacobi_taskfor_blas_ompss2 \
	jacobi_parallelfor_nop2p_blas_mpi | tee ${STARTDIR}/output_jacobi.txt

cd ${STARTDIR}/nanos-cluster-benchmarks/build/cholesky_fare_ompss2
cp ${STARTDIR}/MPI_Benchmarks/build/cholesky_mpi/cholesky_omp_mpi .
./interactive_dim.sh -N 1,2 -R 10 -D 65536 -B 512 -I 0 \
	cholesky_fare_strong_ompss2 \
	cholesky_fare_taskfor_ompss2 \
	cholesky_omp_mpi | tee ${STARTDIR}/output_cholesky.txt

echo "# If you see this line all the benchmarks executed properly.!!"
echo "We can try to process the output files."

cd ${STARTDIR}
./process_dim.py output_*.txt

echo "# If you see this line also the output graphs were generated."
