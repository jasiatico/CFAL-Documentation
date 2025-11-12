# Vega Basics
## Table of Contents
1. [Storage and Compute Environment](#1-storage-and-compute-environment)
2. [Submitting and Managing Jobs](#2-submitting-and-managing-jobs)


## 1. Storage and Compute Environment ##
Upon logging into Vega, you will be placed in your home directory, which is located at `/home2/<yourusername>`.

Vega uses a Linux-based file system, and you can navigate it using standard Linux commands (e.g., `ls`, `cd`, `cp`, `mv`, etc.).

It is also important to understand where to store your files and where your jobs actually run.

### 1.1 File System Layout ###
Vega has two main storage areas:

- **Home Directory**: `/home2/<yourusername>` - Your personal space for files and data.
- **Scratch Space**: `/scratch` - Fast, temporary storage for running jobs and large intermediate files. Typically not backed up on most HPCs.

Best practice:
Work and write output in `/scratch/<yourusername>`, then copy results you want to keep back to `/home2/<yourusername>` when done.


### 1.2 Node Types ###
Most HPCs, including Vega, have different types of nodes optimized for various tasks. Here are the common node types you might encounter:

| Node Type        | Purpose      | Example Hostname       | Usage                           |
|---------------------|-----------------|-----------------|-------------------|
| Login Node   | Where you initially connect. Shared by all users.    | `vegaln1`    | Edit, manage files, and submit jobs only.     |
| Compute Node         | Dedicated hardware for running jobs. Only the scheduled job can use it.   | `cn<##>` (e.g. `cn01`, `cn02`, etc.)   | Run simulations and parallel workloads through the job scheduler.    |

You should not run intensive computations on the login nodes, as this can affect other users. Instead, use them to prepare your job scripts and submit jobs to the compute nodes.

### 1.3 Job Submission ###
By now you should understand Vega's layout and how you should use `/home2` for saving files, `/scratch` for running jobs, and only performing computations on the compute nodes through the job scheduler. But how do you actually access a compute node and how can we use the job scheduler?

When you first log into Vega via SSH, you are placed on a login node and your terminal prompt will look something like this:

`[<yourusername>@vegaln1 ~]$`

where the `vegaln1` part indicates that you are currently on a login node. If you connect to a compute node directly (which typically should not be done unless you are an admin), the prompt would look something like this:

`[<yourusername>@cn01 ~]$` (or whatever compute node you are on)

Okay so, I can only run jobs on a compute node, but I'm not allowed to connect to one directly unless I'm an admin. How do I access a compute node then? This is where the job scheduler comes into play.

### Job Scheduler Analogy ###
Think of it like this: You and many other researchers are department heads in a company. You all have important projects (simulations) that need to be done. There are many employees (compute nodes) available, but if every department head sent tasks directly, it would be chaotic and employees would be overwhelmed. Instead, each department head submits their project requests to a single floor manager (the job scheduler).

The manager:
- Reviews all incoming project requests.
- Checks which employees are free.
- Assigns the right tasks to the right people based on availability and skill (resources like CPU, memory, and runtime).

If all of the employees are busy, the manager will hold your request in a queue until someone becomes available. Once an employee is assigned to your project, they will work on it and report back when it's done. Most clusters also limit how many employees or tasks each department head can use at once to ensure fair and efficient use of the system.

The job scheduler on Vega is managed by the Moab Workload Manager and the underlying resource manager is TORQUE. We won't dive deep into the specifics of Moab and TORQUE, but it's good to know what they are since different clusters may use different job schedulers (e.g., SLURM, PBS, etc.). TORQUE is also a derivative of the original PBS job scheduler, so many PBS commands might also work on Vega. For now we can just treat Moab/TORQUE as a black box that manages job submissions and resource allocation.

## 2. Submitting and Managing Jobs ##
To run anything on Vega, you will need two things:
1. A job scheduler to manage resource allocation and job queuing (Vega uses Moab/TORQUE).
2. A job script that tells the scheduler what to run and what resources to request.

The job script is simply a bash script containing commands and directives that define how many nodes and cores to use, how long the job should run, and what program to execute. Here’s an example job script for running a simple simulation:

```bash
#!/bin/bash
#PBS -N my_simulation_job          # Job name
#PBS -q longq                      # Queue name
#PBS -l nodes=2:ppn=192            # Request 2 nodes with 192 processors per node (total 384 cores)
#PBS -l walltime=02:00:00          # Maximum runtime of 2 hours (HH:MM:SS)

# Load necessary modules (programs/libraries)
module load starccm/versionNumber

# Define environment variables
export LICENSE_FILE=/path/to/license/file

# Execute the simulation (runs starccm+ with the amount of cores specified at the top of the file)
starccm+ -np $PBS_NP $LICENSE_FILE -batch my_simulation_input.sim

# Additional commands can go here to clean up or process results
```

Submit the job to the scheduler with:

```bash
qsub my_job_script.sh
```

This will place your job in the queue. Once resources are available, the scheduler will run it on a compute node and manage everything automatically. Note that this is a crude example and will not actually work on Vega as-is. You will need to modify it based on your specific simulation software, input files, and resource requirements. We will cover this in more detail later and I will provide an example job script tailored for running Star-CCM+ on Vega.

### 2.1 Job Script Directives ###
The lines that start with `#PBS` are directives that tell the scheduler what resources your job needs and how to handle it. These include the job name, queue, node and core counts, memory, walltime, and other settings. They **must be at the top of the script** before any executable commands. Anything above them (except the shebang `#!/bin/bash`) will be ignored by the scheduler.

> **Note about the shebang**  
> The first line `#!/bin/bash` is called a **shebang**. It tells the system to use the **bash shell** to interpret the script, which is standard for most job scripts. Without it, the system might use a different shell (e.g., `sh`, `zsh`, `tcsh`, `ksh`), which could lead to unexpected behavior.  
>
> In simple terms, different shells are like **different programming languages** — each follows its own syntax and rules. A script written for one shell (e.g., `bash`) might not run correctly in another (e.g., `tcsh` or `zsh`). That’s why we include the shebang (`#!/bin/bash`): to ensure the right “language” interprets the commands.  
>
> I won’t go into detail about shells here, but if you’re new to bash, it’s worth skimming a basic tutorial.



Back to the job script directives, here are additional common ones you might use:
<details>
<summary>Example Directives</summary>
<b>Note:</b> The <code>#PBS</code> prefix is omitted below for clarity, but each directive must start with it.

| Directive | Description | Example |
|------------|--------------|----------|
| `-N` | Sets the job name. | `-N LES_Scramjet` |
| `-q` | Specifies which queue to submit to. | `-q longq` |
| `-l nodes=#:ppn=#` | Requests number of nodes and processors per node | `-l nodes=2:ppn=192` |
| `-l mem=#gb` | Requests total memory | `-l mem=16gb` |
| `-l walltime=HH:MM:SS` | hh:mm:ss of time the job should run | `-l walltime=02:00:00` |
| `-o <file>` | Redirects standard output | `-o my_job_output.log` |
| `-e <file>` | Redirects standard error | `-e my_job_error.log` |
| `-M <email>` | Email for job notifications | `-M user@domain.com` |
| `-m <option>` | When to send emails (`b`, `e`, `a`, `n`) | `-m bea` |
| `-A <account>` | Specifies billing/project account | `-A my_project` |

Note that -e and -o can be combined into one file using -j oe to join standard output and error into a single file.
</details>

### 2.2 Available Resources ###
Vega consists of 42 compute nodes, each with 2× AMD EPYC 9654 CPUs (96 cores each) and 1.5 TB RAM, totaling 8,064 cores and 63 TB of memory.
Additionally, there are 2 GPU nodes, each equipped with 4× NVIDIA H100 (80 GB VRAM each) providing 320 GB of GPU memory per node.

To ensure fair usage, users are limited to:
- **Max 4 nodes** (768 cores) per user at a time
- **Max walltime**: 5 days per job (```longq```)
- **Max queued jobs**: 4 additional jobs per user

Example: if you submit 4 jobs using 1 node each, new submissions will wait in the queue until a job finishes. The same applies if a single job uses 4 nodes where no additional jobs can run until it completes. Any additional jobs (up to four) will queue until resources free up. Jobs exceeding these limits will be rejected.

> Vega has 3 queues:
> - `shortq`: for jobs up to 2 hours.
> - `mediumq`: for jobs up to 1 day.
> - `longq`: for jobs up to 5 days.
>
> The choice of queue affects prioritization of jobs. Shortq jobs generally have higher priority than longq jobs. Additionally, jobs with fewer nodes and shorter walltimes are prioritized over larger, longer jobs. This helps ensure that smaller tasks can complete quickly without being blocked by large jobs. Take this into account when selecting the queue and requesting resources.

**Important**: Jobs exceeding their walltime are terminated automatically. Always request slightly more time than you expect, but not excessively.
If a run is nearing its limit, you can stop it manually and resubmit.
Note that directives (e.g., walltime, nodes, ppn) cannot be changed after submission. You must cancel and resubmit the job.

### 2.3 Environment Modules ###
Vega uses the Environment Modules system to manage software and their dependencies.
This allows multiple versions of the same software to coexist without conflict and makes it easy to load or switch between them using the `module` command.
By default, no modules are loaded when you log in.

View all available modules with:

```bash
module avail
```
Search for a specific software:

```bash
module avail <keyword>
```
Load a specific module/version:

```bash
module load <module>/<version>
```

Example:
<details>
<summary>Finding and loading available Star-CCM+ versions</summary>
Here is an example of searching for available Star-CCM+ versions on Vega:

```bash
[username@vegaln1 ~]$ module avail starccm

----- /apps/spack/share/spack/modules/linux-rocky8-zen4 -----
starccm/STAR-CCM+19.02.009-R8  starccm/STAR-CCM+19.04.007-R8  starccm/STAR-CCM+20.04.008-R8

[username@vegaln1 ~]$ module load starccm/STAR-CCM+20.04.008-R8
```
Note that there can be many different versions available depending on what has been installed on the system. This helps ensure compatibility with different simulation requirements.
</details>

**One last note about modules**: Some modules may not appear in the default search path. If you know where a module file is located, you can add its directory to the module search path using:

```bash
module use /path/to/modulefiles
```
On Vega, additional module files are located in `/apps/spack/share/spack/modules/linux-rocky8-zen4/`. You can add this path to your module search path with:

```bash
module use /apps/spack/share/spack/modules/linux-rocky8-zen4/
```

### 2.4 Default Environment Variables ###
When you submit a job, the scheduler automatically sets several environment variables that describe the job and its allocated resources. These can be useful for debugging, logging, or customizing your scripts.

<details>
<summary>Example environment variables</summary>

| Variable | Description |
|------------|--------------|
| `PBS_NODEFILE`  | The path to the run-time generated node list file. In general, it is unnecessary to pass a machinefile parameter to mpirun as the job control system will assign hosts based on the nodes= and ppn= PBS parameters. |
| `PBS_GPUFILE`     | The path to the run-time generated gpu list file, if running on GPU nodes. |
| `PBS_NP`      | The total number of cores that will participate in the parallel job. |
| `PBS_NUM_NODES` | The actual number of compute nodes irrespective of number of cores that will participate in the parallel job. |
| `PBS_NUM_PPN` | The number of processors per node assigned to the job. |
| `PBS_O_WORKDIR` | The directory from which the job was submitted. |
| `PBS_O_HOME` | Home directory of user. |
| `PBS_O_HOST` | Host that job is currently running on. |
| `PBS_JOBID` | The ID that Torque assigned to the job. |
| `PBS_JOBNAME` | The name assigned to the job. |
| `PBS_QUEUE` | The queue in which the job is running. |
</details>

### 2.5 Submitting Jobs ###
Finally, we get to submitting jobs! At this point, you should have a good idea of what each part of the job script does, but there’s one last thing to keep in mind.

Remember how we mentioned running jobs in your scratch space (`/scratch/<yourusername>`) for better performance? If you try to run directly from your home directory, things can slow down a lot because of network file system latency. You might not notice it for small jobs, but for large simulations that read and write a lot of data, it can become a major bottleneck.

In general, it’s best practice to always run jobs from scratch space and only copy back important results to your home directory when finished. My workflow usually looks something like this:

1. Create a project folder in my home directory for organization, e.g., `/home2/<yourusername>/LES_Airfoils/LES_NACA0012_AOA10`. This folder contains all input files (`.sim`, `.java`, `.py`, job submission script, etc.).
2. When I’m ready to run, I submit a job script that:
    - Creates a corresponding folder in my scratch space, e.g., `/scratch/<yourusername>/<jobid>_<jobname>_<date>`.
    - Copies the necessary input files from my home directory to this scratch folder.
    - Changes to the scratch directory.
    - Loads any required modules.
    - Executes the simulation command.
    - After completion, copies back important output files (logs, results, plots) to my home directory.
    - Cleans up the scratch folder to free up space.


This way, all heavy file I/O happens in the fast scratch space, while your home directory stays organized and lightweight. Always keep an eye on both your home and scratch usage to avoid clutter and excessive storage consumption.

You can check disk usage in any directory with:

```bash
du -sh *
```

Be considerate of other users and the overall system limits. Vega has about 1 PB of total storage, but that can fill up quickly when many users are running large simulations. For example, with 100 active users, that’s roughly 10 TB per user on average. That space can disappear fast when dealing with large CFD cases, especially transient simulations that output many time steps.

Make it a habit to regularly clean up old runs and keep only what you truly need. It keeps the system healthy and your workflow much smoother.


### 2.6 Monitoring and Job Control ###
You can monitor the status of your jobs using the `qstat` command:

```bash
[username@vegaln1 ~]$ qstat
Job ID                         Name                User            Time Use  S Queue
------------------------------ ------------------- --------------- --------- - ------------
12345.vegabk.head.cm.vega.era   my_simulation_job  username        00:10:00  R longq
```

Additionally, you can view the entire job queue with `showq` or check detailed job information with `qstat -f <jobid>`, where `<jobid>` is the 5-digit ID of your job. So in the example above you would run `qstat -f 12345`.

Finally, if you need to cancel a job, you can use the `canceljob <jobid>` command. This will terminate the job without saving or waiting for it to complete. Use this command if a job is misconfigured, no longer needed, or stuck.

---

Next Topic:
[Running Star-CCM+ Jobs](./03_StarCCM_Jobs.md)