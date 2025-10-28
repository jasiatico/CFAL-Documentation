# Vega - High Performance Computing (HPC)

I would like to preface this document by stating that I am not an HPC expert. The information provided here is based on my own experiences and research. If you are an HPC expert and notice any inaccuracies or have suggestions for improvement, please feel free to contribute or reach out to me.

![HPCExample](docs/HPC_Image.jpg)
[Source: Julios Blog](https://www.juliosblog.com/high-performance-computing-hpc-on-openstack-a-few-recommendations/)

Above is an example of what a high performance computing (HPC) cluster might look like. HPC clusters are used for complex computations that require significant processing power, such as scientific simulations, data analysis, and machine learning tasks.

## 1. What is an HPC? ##

An HPC (High Performance Computing) cluster is a **group of powerful interconnected computers (nodes)** that work together to perform complex computations much faster than a single computer.

Each node has its own CPU, memory, and storage, and all nodes communicate over a high-speed network to act as one system. While a personal computer might have 4–16 cores and up to 64 GB of RAM, an HPC cluster can include hundreds or thousands of nodes, each with dozens of cores and hundreds of gigabytes or even terabytes of memory.

This setup allows large-scale simulations, data processing, and scientific calculations to be completed in a fraction of the time it would take on a single machine.

Here is a general breakdown of what different machines might look like:
| Machine Type        | Example Hardware       | Total Cores       | Total RAM               | Runtime**                         |
|---------------------|-----------------|-----------------|-------------------|------------------------------------|
| Personal Computer   | AMD Ryzen 9 7950X    | 16    | 32 GB      | ~14 days    |
| Workstation         | AMD EPYC 9654   | 96   | 256 GB   | ~3 days     |
| **Vega**          | 42 nodes with x2 AMD EPYC 9654 per node  | 8,064  | 63 TB    | ~11–12 hours      |
| NASA Pleiades      | Mixture of hardware | 232,416 | 873 TB | ~5–6 hours |

Runtimes are made up and just used as an example. Actual runtimes will vary based on the specific hardware, software, and workload. Additionally, the amount of cores and RAM a single user can access may be limited by the HPC administrators to ensure fair usage among all users, therefore the total available resources may not be fully accessible to a single user. The above is just to illustrate the scale of resources available in an HPC cluster compared to personal computers and workstations. The "approximate runtimes" are thus also based on the assumption that a single user is only using a fraction of the total resources available on the HPC cluster. Lastly, it is also important to note that utilizing more cores does not always lead to a linear decrease in runtime due to overhead from communication between nodes and other factors which will be discussed later.

### You should use a HPC when: ###
- Your computations need **more processing power or memory** than your computer or workstation can provide.
- The workload can be **split into smaller, independent parts** that run in parallel
- You need to run **many simulations** or data analyses **simultaneously**.
- You want to free up your local computer while long jobs run remotely.

### You should NOT use a HPC when: ###
- Your tasks run quickly on your local computer or don’t need high performance.
- The code cannot run in parallel (or isn’t designed for it).
- You’re doing interactive or graphical work (e.g., GUI tools, plotting large data live).

## 2. Logging in and Setup ##

WIP

## 3. Storage and Compute Environment ##
Upon logging into Vega, you will be placed in your home directory, which is located at `/home2/<yourusername>`.

Vega uses a Linux-based file system, and you can navigate it using standard Linux commands (e.g., `ls`, `cd`, `cp`, `mv`, etc.).

It is also important to understand where to store your files and where your jobs actually run.

### 3.1 File System Layout ###
Vega has two main storage areas:

- **Home Directory**: `/home2/<yourusername>` - Your personal space for files and data.
- **Scratch Space**: `/scratch` - Fast, temporary storage for running jobs and large intermediate files. Typically not backed up on most HPCs.

Best practice:
Work and write output in `/scratch/<yourusername>`, then copy results you want to keep back to `/home2/<yourusername>` when done.


### 3.2 Node Types ###
Most HPCs, including Vega, have different types of nodes optimized for various tasks. Here are the common node types you might encounter:

| Node Type        | Purpose      | Example Hostname       | Usage                           |
|---------------------|-----------------|-----------------|-------------------|
| Login Node   | Where you initially connect. Shared by all users.    | `vegaln1`    | Edit, manage files, and submit jobs only.     |
| Compute Node         | Dedicated hardware for running jobs. Only the scheduled job can use it.   | `cn<##>` (e.g. `cn01`, `cn02`, etc.)   | Run simulations and parallel workloads through the job scheduler.    |

You should not run intensive computations on the login nodes, as this can affect other users. Instead, use them to prepare your job scripts and submit jobs to the compute nodes.

### 3.2 Job Submission ###
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

The job scheduler on Vega is managed by the Moab Workload Manager and the underlying resource manager is TORQUE. We won't dive deep into the specifics of Moab and TORQUE, but it's good to know what they are since different clusters may use different job schedulers (e.g., SLURM, PBS, etc.). TORQUE is also a derivative of the original PBS job scheduler, so many PBS commands might also work on Vega.

## 4. Submitting and Managing Jobs ##