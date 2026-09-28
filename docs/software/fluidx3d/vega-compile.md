# Building FluidX3D on Vega

[FluidX3D](https://github.com/ProjectPhysX/FluidX3D) is an open-source lattice Boltzmann (LBM) CFD solver that runs on GPUs. This guide covers getting it to compile on Vega's H100 GPU nodes, which needs one change to its Makefile and a specific CUDA setup.

> [!NOTE]
> Written July 9, 2025. The CUDA module name below contains a build hash that may have changed since then. Run `module avail cuda` on Vega to find the current name. The Makefile block in step 3 may also look different in newer FluidX3D versions.

---

## What is FluidX3D?

FluidX3D simulates incompressible flow using the lattice Boltzmann method. It is heavily optimized for GPUs (through OpenCL) and is well suited to high-resolution runs with built-in visualization. On Vega it can run in near real time, depending on domain size and GPU count.

If you haven't used Vega's GPU nodes before, read [GPU Computing](../../cluster/vega/getting-started/06_gpu_computing.md) first.

## Vega environment

As of July 9, 2025:

| Item | Value |
|------|-------|
| Operating system | Rocky Linux 8.7 |
| GPU nodes | 2 nodes, each with 4× NVIDIA H100 PCIe |
| CUDA toolkit | 12.2.0 (loaded as a module) |
| Driver version | 535.129.03 (supports CUDA 12.2) |
| `nvcc` version | 12.2.91 |
| Job scheduler | Moab/TORQUE |

---

## 1. Clone FluidX3D

On the login node, clone the repository into your home directory:

```bash
git clone https://github.com/ProjectPhysX/FluidX3D.git
cd FluidX3D
```

## 2. Make the build script executable

FluidX3D is built with its `make.sh` script, which needs permission to run:

```bash
chmod +x make.sh
```

## 3. Fix the Makefile

FluidX3D uses the C++17 `<filesystem>` library. With the compiler available on Vega, this needs an extra linker flag, `-lstdc++fs`, which the default `Makefile` doesn't include. Without it, the build fails with unresolved references to `std::filesystem` symbols.

Open `Makefile` in the FluidX3D folder and find this block:

```makefile
bin/FluidX3D: temp/graphics.o temp/info.o temp/kernel.o temp/lbm.o temp/lodepng.o temp/main.o temp/setup.o temp/shapes.o make.sh
	@mkdir -p bin
	$(CC) temp/*.o -o bin/FluidX3D $(CFLAGS) $(LDFLAGS_OPENCL) $(LDLIBS_OPENCL) $(LDFLAGS_X11) $(LDLIBS_X11)
```

Add `-lstdc++fs` to the end of the `$(CC)` line:

```makefile
bin/FluidX3D: temp/graphics.o temp/info.o temp/kernel.o temp/lbm.o temp/lodepng.o temp/main.o temp/setup.o temp/shapes.o make.sh
	@mkdir -p bin
	$(CC) temp/*.o -o bin/FluidX3D $(CFLAGS) $(LDFLAGS_OPENCL) $(LDLIBS_OPENCL) $(LDFLAGS_X11) $(LDLIBS_X11) -lstdc++fs
```

## 4. Set up CUDA on a GPU node

The build must happen on a GPU node, where the CUDA libraries and GPUs are available. `make.sh` also **starts the simulation immediately** after compiling, so don't run it on the login node. Run these commands inside a GPU job (see [Submitting a GPU Job](../../cluster/vega/getting-started/06_gpu_computing.md)):

```bash
module purge
module use /apps/spack/share/spack/modules/linux-rocky8-zen4
module load cuda/12.2.0-gcc-13.2.0-nwhgfor

export CPLUS_INCLUDE_PATH=$CUDA_HOME/targets/x86_64-linux/include:$CPLUS_INCLUDE_PATH
export LIBRARY_PATH=/usr/local/cuda/targets/x86_64-linux/lib:$LIBRARY_PATH
export LD_LIBRARY_PATH=/usr/local/cuda/targets/x86_64-linux/lib:$LD_LIBRARY_PATH
```

These settings let the compiler and linker find the CUDA headers and libraries.

## 5. Build and run

From the FluidX3D folder, on the GPU node:

```bash
./make.sh
```

This compiles FluidX3D and, if the build succeeds, runs the simulation defined in its `src/setup.cpp`.

---

## Next steps

Setting up your own cases, configuring simulation parameters, visualizing results and benchmarking are all covered in the official documentation, which this guide doesn't duplicate:

[FluidX3D documentation on GitHub](https://github.com/ProjectPhysX/FluidX3D/blob/master/DOCUMENTATION.md)
