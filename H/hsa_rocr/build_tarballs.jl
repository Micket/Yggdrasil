# Note that this script can accept some limited command-line arguments, run
# `julia build_tarballs.jl --help` to see a usage message.
using BinaryBuilder

name = "hsa_rocr"
version = v"3.5.0"

# Collection of sources required to build
sources = [
    ArchiveSource("https://github.com/RadeonOpenCompute/ROCR-Runtime/archive/rocm-$(version).tar.gz",
                  "52c12eec3e3404c0749c70f156229786ee0c3e6d3c979aed9bbaea500fa1f3b8")
]

# Bash recipe for building across all platforms
script = raw"""
cd ${WORKSPACE}/srcdir/ROCR-Runtime*/

mkdir build && cd build
cmake -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INSTALL_PREFIX=${prefix} \
      -DCMAKE_TOOLCHAIN_FILE=${CMAKE_TARGET_TOOLCHAIN} \
      -DCMAKE_SKIP_RPATH=ON \
      ../src
make -j${nproc}
make install
"""

# These are the platforms we will build for by default, unless further
# platforms are passed in on the command line
# Only supports Linux, seemingly only 64bit
platforms = [
    Linux(:x86_64, libc=:glibc),
]
platforms = expand_cxxstring_abis(platforms)

# The products that we will ensure are always built
products = [
    LibraryProduct(["libhsa-runtime64"], :libhsa_runtime64),
]

# Dependencies that must be installed before this package can be built
dependencies = [
    Dependency("hsakmt_roct_jll"),
    Dependency("NUMA_jll"),
    Dependency("Zlib_jll"),
    Dependency("Elfutils_jll"),
]

# Build the tarballs, and possibly a `build.jl` as well.
build_tarballs(ARGS, name, version, sources, script, platforms, products, dependencies,
               preferred_gcc_version=v"8") 
