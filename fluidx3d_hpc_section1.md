
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

## 🧑‍🔬 Who Should Use This Manual

This manual is for:

- New and returning **student researchers** working on fluid simulation or related research
- Anyone unfamiliar with the process of building GPU-accelerated applications on a Linux HPC
- Researchers looking for reproducible instructions for running FluidX3D simulations in our lab environment

## ⚙️ Cluster Overview

Our internal HPC cluster has the following environment:

- **Operating System:** Rocky Linux 8.7  
- **Nodes:** Each node contains **4× NVIDIA H100 PCIe GPUs**  
- **CUDA Toolkit:** 12.2.0 (loaded via environment modules)  
- **Driver Version:** 535.129.03 (supports CUDA 12.2)  
- **nvcc Version:** 12.2.91  
- **Job Scheduler:** Moab/Torque (access via `msub -I`)  
- **No external internet access from compute nodes**  

## ✅ Prerequisites

To follow this guide, you should:

- Have a valid HPC user account with shell access
- Be able to SSH into the head node
- Be assigned to a project that uses GPUs
- Know basic Linux command-line operations (e.g., `cd`, `ls`, `nano`, etc.)
- Be familiar with how modules are loaded on the cluster (e.g., `module load`)

## 🧱 Key Concepts Introduced

This guide teaches you the following concepts step-by-step:

| Topic | What You’ll Learn |
|-------|--------------------|
| Git Basics | How to clone a GitHub repo (FluidX3D) |
| File Permissions | Why we run `chmod +x` |
| Makefiles | What a Makefile does and how we modify it |
| HPC Interactive Sessions | Using `msub -I` to run jobs on a GPU node |
| Modules | How to load CUDA and configure the environment |
| Compilation | Building FluidX3D on the GPU node with the correct libraries |
| Simulation Execution | Running your first test case |

## 🛠️ What You Will Build

By the end of this guide, you'll be able to:

- Clone and compile the **FluidX3D** source code
- Adjust the Makefile for compatibility with your CUDA environment
- Load and configure the GPU environment on our cluster
- Start and monitor simple 3D fluid simulations
- Run simulations from interactive GPU sessions

## 📝 Guide Structure

The rest of this guide is divided into concise but thorough sections:

| Section | Description |
|---------|-------------|
| **2. Installing FluidX3D on the Head Node** | Cloning the repository, making it executable |
| **3. Modifying the Makefile** | How and why to update the build commands |
| **4. Accessing the GPU Node** | Running interactive jobs using `msub -I` |
| **5. CUDA Module Setup** | Loading CUDA and configuring environment variables |
| **6. Building FluidX3D** | Compiling the software with CUDA support |
| **7. Running a Simulation** | Running your first case |
| **8. Best Practices** | Tips for maintaining stability, reproducibility, and performance |

## 📎 Markdown Notes for GitHub Deployment

If you’re placing this in a GitHub repository:

- Save each section as separate `.md` files in a `/docs` folder or use one `README.md`  
- Consider adding collapsible code blocks for readability:  

```md
<details>
<summary>Click to expand</summary>

```bash
your code here
```

</details>
```

- Add links between sections using anchor tags for navigation

## 📍 Next Steps

Now that you've reviewed the purpose and structure of this guide, you're ready to begin.
