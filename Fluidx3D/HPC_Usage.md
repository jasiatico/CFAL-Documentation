
# 🚀 FluidX3D on the HPC Cluster  
## Section 1: Introduction & Training Objectives

Welcome to the **FluidX3D HPC Training Manual** for student researchers at the **Computational Fluid and Aerodynamics Laboratory**. This guide is designed to help you get up and running with FluidX3D on our internal high-performance computing (HPC) cluster. It is structured specifically for students who may be new to high-performance computing, Linux command-line tools, or scientific simulation platforms.

## 📚 What is FluidX3D?

[FluidX3D](https://github.com/ProjectPhysX/FluidX3D) is an open-source, highly optimized Lattice Boltzmann Method (LBM) simulator for fluid dynamics. It’s GPU-accelerated using CUDA and OpenCL, and ideal for research applications that require high resolution, rapid simulation, and visualization.

FluidX3D enables:

- 3D simulations of incompressible flow
- Fast computation using GPUs (specifically NVIDIA H100s in our cluster)
- Real-time or near real-time performance depending on domain size and GPU count

## 🎯 Purpose of This Guide

This guide provides **step-by-step instructions** to:

- Clone and configure FluidX3D from GitHub
- Modify the build system for compatibility with our HPC cluster
- Load necessary modules (e.g., CUDA)
- Run and manage simulations from GPU-enabled compute nodes

## ⚙️ Cluster Overview

Our internal HPC cluster, Vega, has the following environment as of July 9, 2025:

- **Operating System:** Rocky Linux 8.7  
- **Nodes:** Each node contains **4× NVIDIA H100 PCIe GPUs**  
- **CUDA Toolkit:** 12.2.0 (loaded via environment modules)  
- **Driver Version:** 535.129.03 (supports CUDA 12.2)  
- **nvcc Version:** 12.2.91  
- **Job Scheduler:** Moab/Torque  


---


## 🛠️ Section 2: Installing FluidX3D on the Head Node

Follow these steps to install the FluidX3D source code and prepare the project for compilation.

### 1️⃣ Clone the FluidX3D Repository

First, SSH into the **head node** of the cluster (not a compute node), then clone the FluidX3D GitHub repository:

```bash
git clone https://github.com/ProjectPhysX/FluidX3D.git
cd FluidX3D
```

### 2️⃣ Make the Build Script Executable

The repository contains a `make.sh` script used to build the code. It needs to be made executable:

```bash
chmod +x make.sh
```

This gives the script permission to be run as a program.

&nbsp;

---

&nbsp;

## 🧾 Section 3: Modifying the Makefile

Before compiling FluidX3D, you need to modify the `Makefile` to ensure it links correctly with the C++ filesystem library required by the CUDA toolkit and your compiler.

### 🔧 Why Modify the Makefile?

By default, the `Makefile` provided by FluidX3D does **not** include the `-lstdc++fs` linker flag. This is needed on some systems (like ours) when using C++17 features such as the `<filesystem>` header, which FluidX3D uses internally.

Without this flag, the build may fail with an error related to unresolved references to `std::filesystem` symbols.

### ✏️ Instructions

1. Open the `Makefile` located in the root of the `FluidX3D` directory.

2. Locate this block:

```makefile
bin/FluidX3D: temp/graphics.o temp/info.o temp/kernel.o temp/lbm.o temp/lodepng.o temp/main.o temp/setup.o temp/shapes.o make.sh
	@mkdir -p bin
	$(CC) temp/*.o -o bin/FluidX3D $(CFLAGS) $(LDFLAGS_OPENCL) $(LDLIBS_OPENCL) $(LDFLAGS_X11) $(LDLIBS_X11)
```

3. Replace it with this modified version:

```makefile
bin/FluidX3D: temp/graphics.o temp/info.o temp/kernel.o temp/lbm.o temp/lodepng.o temp/main.o temp/setup.o temp/shapes.o make.sh
	@mkdir -p bin
	$(CC) temp/*.o -o bin/FluidX3D $(CFLAGS) $(LDFLAGS_OPENCL) $(LDLIBS_OPENCL) $(LDFLAGS_X11) $(LDLIBS_X11) -lstdc++fs
```

The only difference is the **addition of `-lstdc++fs`** at the end of the `$(CC)` line.


---


## 🚦 Section 4: Building and Running FluidX3D

With the environment configured and the Makefile updated, you're now ready to compile and run FluidX3D.

### 📦 GPU Node Environment Setup

Before compiling, make sure you have loaded the appropriate modules and set the environment variables on the **GPU node**:

```bash
module purge
module use /apps/spack/share/spack/modules/linux-rocky8-zen4
module load cuda/12.2.0-gcc-13.2.0-nwhgfor

export CPLUS_INCLUDE_PATH=$CUDA_HOME/targets/x86_64-linux/include:$CPLUS_INCLUDE_PATH
export LIBRARY_PATH=/usr/local/cuda/targets/x86_64-linux/lib:$LIBRARY_PATH
export LD_LIBRARY_PATH=/usr/local/cuda/targets/x86_64-linux/lib:$LD_LIBRARY_PATH
```

These settings ensure the compiler and linker can find the required CUDA headers and libraries for FluidX3D.

### ▶️ Compile the Code

Once you've set up the environment, build FluidX3D by running:

```bash
./make.sh
```

This script compiles the source files and, if successful, immediately runs the FluidX3D simulation using the generated binary.

### 📘 Next Steps

Instead of duplicating instructions here, please refer directly to the **official FluidX3D user guide** for how to prepare and launch simulations:

🔗 [FluidX3D GitHub Documentation](https://github.com/ProjectPhysX/FluidX3D/blob/master/DOCUMENTATION.md)

This includes how to:

- Set up input files
- Configure simulation parameters
- Visualize results
- Benchmark performance