# Vega Hardware Reference

This page is a short and concise reference for Vega's hardware and software specifications.

---

## Hardware

### CPU Compute Nodes
- **Count:** 42 nodes
- **CPUs:** 2× AMD EPYC 9654 per node (96 cores/CPU, 192 cores/node)
- **Architecture:** AMD Zen 4, 5nm, 2.4 GHz base clock, 3.7 GHz boost clock
- **RAM:** 1.5 TB per node
- **Total:** 8,064 cores, 63 TB memory

### GPU Nodes
- **Count:** 2 nodes
- **GPUs:** 4× NVIDIA H100 per node (80 GB VRAM each)
- **Architecture:** NVIDIA Hopper, 3rd generation Tensor Cores
- **GPU Memory:** 320 GB per node
- **CPU/RAM:** Same as compute nodes (192 cores, 1.5 TB RAM)

### Interconnect
- **100Gb InfiniBand** between all nodes

### Storage
- **Home Storage:** 1 PB (`/home2/`) — backed up, for scripts and results
- **Scratch Space:** 1 PB (`/scratch/`) — high-performance Lustre file system, not backed up

---

## System

| Component | Details |
|-----------|---------|
| Operating System | Rocky Linux 8.7 (Green Obsidian) |
| Job Scheduler | Moab Workload Manager |
| Resource Manager | TORQUE |

---

## Per-User Limits

| Limit | Value |
|-------|-------|
| Max nodes per user | 4 nodes (768 cores) |
| Max walltime per job | 5 days (`longq`) |
| Max queued jobs | 4 additional jobs |

### Queues

| Queue | Max Walltime |
|-------|-------------|
| `shortq` | 2 hours |
| `mediumq` | 1 day |
| `longq` | 5 days |

---

## Installed Software

| Software | Available Versions |
|----------|--------------------|
| Star-CCM+ | 19.02.009-R8, 19.04.007-R8, 20.04.008-R8, and more |
| ANSYS Fluent | R2310, R2410, R2510 |
| OpenFOAM | 2.4.0, 1912_220610, 2312 |

> [!NOTE]
> This list is not exhaustive. Run `module avail` on Vega to see all installed software.