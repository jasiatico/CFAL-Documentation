# Summary of Vega Hardware/Software ##
### Hardware ###
- **Compute Nodes**: 42 nodes, each with 2× AMD EPYC 9654 CPUs (96 cores each) and 1.5 TB RAM, totaling 8,064 cores and 63 TB of memory.
- **GPU Nodes**: 2 nodes, each with 4× NVIDIA H100 (80 GB VRAM each) providing 320 GB of GPU memory per node.
- **Interconnect**: 100Gb InfiniBand port
- **Storage**: 1 PB of shared storage user home storage and 1 PB of high-performance scratch space (Lustre file system).
- **Job Scheduler**: Moab Workload Manager with TORQUE resource manager.
- **Operating System**: Rocky Linux 8.7 (Green Obsidian)
- **CPU Architecture**: AMD Zen 4, 5nm, 2.4 GHz base clock, 3.7 GHz boost clock.
- **GPU Architecture**: NVIDIA Hopper H100, 80 GB VRAM, 3rd generation Tensor Cores.

### Software ###
- **Over 100 scientific and engineering applications**
- **Star-CCM+**: 19.02.009-R8, 19.04.007-R8, 20.04.008-R8
- **ANSYS Fluent**: R2310, R2410, R2510
- **OpenFOAM**: 2.4.0 (OpenFOAM-org), 1912_220610, 2312