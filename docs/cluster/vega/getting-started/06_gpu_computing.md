# GPU Computing

Vega has two dedicated GPU nodes available for workloads that can take advantage of GPU acceleration. This page explains how GPU computing differs from CPU computing, when to use it, and how to submit GPU jobs.

---

## 1. CPU vs. GPU: What is the Difference?

CPU and GPU computing are fundamentally different in how they approach parallelism.

**CPUs** have a relatively small number of powerful cores (Vega's nodes have 192) designed to handle complex, sequential logic quickly. They are general-purpose and well-suited for most simulation workloads.

**GPUs** have thousands of much simpler cores designed to perform the same operation on many pieces of data simultaneously. A single NVIDIA H100 has over 16,000 CUDA cores. This makes GPUs extremely fast for workloads that are highly parallelizable and mathematically regular — but they are not a drop-in replacement for CPUs. The software must be specifically written or configured to run on a GPU.

A useful analogy: a CPU is like a small team of expert engineers who can each solve complex, varied problems independently. A GPU is like a massive assembly line — incredibly fast when every station is doing the same task, but inefficient for varied or sequential work.

---

## 2. When to Use GPU Nodes

**Good candidates for GPU computing:**
- Machine learning and deep learning training or inference (PyTorch, TensorFlow)
- GPU-accelerated solvers (e.g., Star-CCM+ GPU solver, ANSYS Fluent GPU)
- Molecular dynamics simulations
- Image processing or computer vision pipelines
- Any software explicitly documented to support GPU acceleration

**Not well suited for GPU computing:**
- Standard CFD runs that are not GPU-enabled
- Meshing (most meshers are CPU-only)
- Pre- and post-processing tasks
- General scripting or data wrangling

If you are unsure whether your software supports GPU acceleration, check its documentation or ask before requesting GPU resources.

---

## 3. Vega GPU Hardware

Vega has **2 GPU nodes**, each equipped with:
- **4× NVIDIA H100** (80 GB VRAM each)
- **320 GB total GPU memory** per node
- Same CPU and RAM as compute nodes (192 cores, 1.5 TB RAM)

For full hardware specs, see [Vega Hardware Reference](../reference/vega_hardware.md).

---

## 4. Submitting a GPU Job

GPU jobs are submitted the same way as CPU jobs — using a job script and `msub` — but with an additional directive to request GPU resources.

### Requesting GPUs in your job script

Add the following directive to request GPUs:

```bash
#PBS -l nodes=1:ppn=192:gpus=4    # Request 1 GPU node with all 4 GPUs
```

You can request fewer GPUs if your job does not need all four:

```bash
#PBS -l nodes=1:ppn=64:gpus=1     # Request 1 GPU and 64 CPU cores
```

### Example GPU job script

```bash
#!/bin/bash
#PBS -N my_gpu_job
#PBS -q longq
#PBS -l nodes=1:ppn=192:gpus=4
#PBS -l walltime=12:00:00

# Load necessary modules
module purge
module use /apps/spack/share/spack/modules/linux-rocky8-zen4
module load <your_gpu_software>/<version>

# The scheduler sets this variable to a file listing allocated GPUs
echo "GPUs allocated: $PBS_GPUFILE"
cat $PBS_GPUFILE

# Run your GPU-enabled program
your_program --gpu ...
```

### The `PBS_GPUFILE` variable

When the scheduler allocates GPU resources, it sets the `$PBS_GPUFILE` environment variable to the path of a file listing the allocated GPUs. Some GPU-enabled software reads this automatically; others require you to pass GPU IDs explicitly. Check your software's documentation for how it handles GPU assignment.

---

## 5. Checking GPU Availability

To see whether the GPU nodes are currently in use, you can check the job queue:

```bash
showq
```

Look for jobs running on `gpu01` or `gpu02` (the GPU node hostnames). If they are idle, your job should start promptly after submission.

---

> [!TIP]
> GPU computing on Vega is an evolving area. If you are working with a specific GPU-accelerated tool and need help setting it up, reach out to the lab.

---

Next: [Software](../../../software/index.md), for guides and job scripts for specific tools on Vega