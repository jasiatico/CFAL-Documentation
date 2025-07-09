
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