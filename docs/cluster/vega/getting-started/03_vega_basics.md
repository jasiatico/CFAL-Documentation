# Vega Basics

This page covers the essential concepts you need to understand before running anything on Vega — how the file system is laid out, what types of nodes exist, and how the job scheduler works.

---

## 1. File System Layout

When you log into Vega, you are placed in your **home directory**:

```
/home2/<yourusername>
```

Vega uses a Linux-based file system. If you are unfamiliar with basic Linux commands (`ls`, `cd`, `cp`, `mv`, etc.), it is worth skimming a quick reference before getting started.

Vega has two main storage areas:

| Location | Path | Purpose |
|----------|------|---------|
| Home Directory | `/home2/<yourusername>` | Personal storage for scripts, input files, and results you want to keep. |
| Scratch Space | `/scratch/<yourusername>` | Fast temporary storage for active jobs and large intermediate files. Not backed up. |

**Best practice:** Run jobs and write output in `/scratch`, then copy results you want to keep back to `/home2` when done. This is covered in more detail in [Job Submission](./05_job_submission.md).

---

## 2. Node Types

Vega has two types of nodes, each serving a different purpose:

| Node Type | Purpose | Example Hostname |
|-----------|---------|-----------------|
| Login Node | Where you land when you first connect. Shared by all users. | `vegaln1` |
| Compute Node | Dedicated hardware for running jobs. | `cn01`, `cn02`, etc. |

When you connect via SSH, your terminal prompt will show which node you are on:

```bash
[username@vegaln1 ~]$       # You are on a login node
[username@cn01 ~]$          # You are on a compute node
```

**Do not run intensive computations on the login node.** It is shared by everyone and is only meant for editing files, managing data, and submitting jobs. All heavy work must go through the job scheduler and run on compute nodes. It *is* fine to run very light commands/python scripts on the login node for testing or very quick tasks, but if you are doing anything that takes more than a minute, you should be running it as a job on a compute node.

---

## 3. The Job Scheduler

An HPC is very different from your personal computer. I can open STAR-CCM+ directly on my laptop and click run. On Vega, in order to keep the system from getting bogged down you must submit your job to a **job scheduler**. You tell the scheduler what resources you need (e.g., number of nodes, CPU cores, memory, walltime), and it will queue your job and run it when those resources are available.

### How it works

Think of it like this: you and many other researchers are department heads in a company. You all have important projects (simulations) that need to get done. There are many employees (compute nodes) available, but if every department head sent tasks directly to the compute nodes, it would be chaotic. Instead, everyone submits requests to a single floor manager — the job scheduler. This avoids conflicts and ensures that every project gets the resources it needs in an organized way.

The scheduler:
- Reviews all incoming job requests
- Checks which compute nodes are free
- Assigns jobs based on available resources (CPU, memory, walltime)
- Holds jobs in a queue if resources are unavailable

Vega uses the **Moab Workload Manager** with **TORQUE** as the underlying resource manager. Other clusters may use different schedulers (e.g., SLURM, PBS), but the concepts are the same. TORQUE is also a derivative of PBS, so many PBS commands work on Vega as well. This is not super important to understand right now, but it is very helpful to know when you start working with other HPCs in the future.

---

## 4. Environment Modules

Vega uses the **Environment Modules** system to manage software. This allows multiple versions of the same software to coexist without conflict. For example, ```starccm+``` is the command to open STAR-CCM+. If I have multiple versions installed, how does the system know which one to run when I type `starccm+`? Modules solve this problem by forcing the user to explicitly load the version they want to use. By default, no modules are loaded when you log in.

Common commands:

```bash
# List all available modules
module avail

# Search for a specific software
module avail <keyword>

# Load a specific module
module load <module>/<version>

# Unload all currently loaded modules
module purge
```

**Example — finding and loading Star-CCM+:**

```bash
[username@vegaln1 ~]$ module avail starccm

----- /apps/spack/share/spack/modules/linux-rocky8-zen4 -----
starccm/STAR-CCM+19.02.009-R8  starccm/STAR-CCM+19.04.007-R8  starccm/STAR-CCM+20.04.008-R8

[username@vegaln1 ~]$ module load starccm/STAR-CCM+20.04.008-R8
```

If a module does not appear in the default search, you may need to add its directory to the module path first:

```bash
module use /apps/spack/share/spack/modules/linux-rocky8-zen4/
```

---

## 5. Checking Storage Usage

You can check how much space you are using in any directory with:

```bash
du -sh *
```

Vega has approximately 1 PB of total storage, but that fills up quickly with many users running large simulations. Be considerate — regularly clean up old runs and keep only what you truly need.

---

Next: [Resource Planning](./04_resource_planning.md)