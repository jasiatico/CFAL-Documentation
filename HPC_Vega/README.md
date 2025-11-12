# Vega - High Performance Computing (HPC)

I would like to preface this document by stating that I am not an HPC expert. The information provided here is based on my own experiences and research. If you are an HPC expert and notice any inaccuracies or have suggestions for improvement, please feel free to contribute or reach out to me.

Note that connecting to Vega (or other remote machines) usually requires VPN access unless you’re on a campus wired network, as well as valid authentication credentials. Details on this are not covered here.

![HPCExample](images/HPC_Image.jpg)
[Source: Julios Blog](https://www.juliosblog.com/high-performance-computing-hpc-on-openstack-a-few-recommendations/)

Above is an example of what a high performance computing (HPC) cluster might look like. HPC clusters are used for complex computations that require significant processing power, such as scientific simulations, data analysis, and machine learning tasks.

## 1. What is an HPC? ##

An HPC (High Performance Computing) cluster is a **group of powerful interconnected computers (nodes)** that work together to perform complex computations much faster than a single computer.

Each node has its own CPU, memory, and storage, and all nodes communicate over a high-speed network to act as one system. While a personal computer might have 4–16 cores and up to 64 GB of RAM, an HPC cluster can include hundreds or thousands of nodes, each with dozens of cores and hundreds of gigabytes or even terabytes of memory.

![HPCCluster](images/HPCWorkflow.png)

This setup allows large-scale simulations, data processing, and scientific calculations to be completed in a fraction of the time it would take on a single machine.

Here is a general breakdown of what different machines might look like:
| Machine Type        | Example Hardware       | Total Cores       | Total RAM               | Runtime**                         |
|---------------------|-----------------|-----------------|-------------------|------------------------------------|
| Personal Computer   | AMD Ryzen 9 7950X    | 16    | 32 GB      | ~14 days    |
| Workstation         | AMD EPYC 9654   | 96   | 256 GB   | ~3 days     |
| **Vega**          | 42 nodes with x2 AMD EPYC 9654 per node  | 8,064  | 63 TB    | ~11–12 hours      |
| NASA Pleiades      | Mixture of hardware | 232,416 | 873 TB | ~5–6 hours |

The above runtimes are made up for illustrative purposes. Actual runtimes will vary based on the specific hardware, software, and simulation physics. There are also some additional nuances to consider, such as administrative limits on resources you can use and the non-linear scaling of performance with increased cores, which will be discussed later. The key takeaway is that HPC clusters like Vega provide a massive increase in computational power compared to personal computers and workstations, enabling researchers to tackle problems that would otherwise be infeasible. (If anyone has any realistic runtime estimates for different hardware setups running Star-CCM+ simulations, please let me know so I can update the table above.)


### You should use a HPC when: ###
- Your computations need **more processing power or memory** than your computer or workstation can provide.
- The workload can be **split into smaller, independent parts** that run in parallel
- You need to run **many simulations** or data analyses **simultaneously**.
- You want to free up your local computer while long jobs run remotely.

### You should NOT use a HPC when: ###
- Your tasks run quickly on your local computer or don’t need high performance.
- The code cannot run in parallel (or isn’t designed for it).
- You’re doing interactive or graphical work (e.g., GUI tools, plotting large data live).


## Table of Contents
1. [Accessing Vega with VS Code](docs/01_Access_Setup.md)
2. [Vega Basics and Job Submission](docs/02_Vega_Basics.md)
3. [Running Star-CCM+ Jobs](docs/03_StarCCM_Jobs.md)
4. [Resource Planning and Performance](docs/04_Resource_Selection.md)
5. [Summary of Vega Hardware/Software](docs/Appendix_Vega_Reference.md)