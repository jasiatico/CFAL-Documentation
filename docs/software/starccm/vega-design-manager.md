# Star-CCM+ — Design Manager

Design Manager is used when you want to run multiple Star-CCM+ cases that differ by geometry, boundary conditions, or parameters — such as parameter sweeps, design of experiments (DOE), or optimization studies. Instead of manually submitting each case, Design Manager coordinates and tracks them all within a single job allocation.

For running a single simulation, see [Single Case](./vega-single-case.md).

---

## Prerequisites

Before submitting, make sure you have:
- A configured Design Manager project file (`.dmprj`)
- Your `.sim` file referenced inside the Design Manager project
- A valid license key or license server address
- **"Linux Cluster" selected as the compute resource** inside the Design Manager project file — this is required for the pre-allocation method used on Vega

---

## How Design Manager Works on Vega

Vega requires the **pre-allocation method**, meaning you request all resources upfront in your job script. Design Manager then uses that allocation to run multiple cases in parallel, up to the number of simultaneous jobs you configure.

For example, if you request 2 nodes (384 cores) and configure Design Manager to run 4 simultaneous jobs at 96 cores each, it will keep up to 4 cases running at a time until all cases in the project are complete.

> [!NOTE]
> There is an alternative method called General Job Submission where the Design Manager controller submits individual jobs to the scheduler as cases complete. This is not supported on Vega. Documentation for this method is coming soon.

---

## User Inputs

The `USER INPUTS` section at the top of the script is the only part you should need to edit:

| Variable | Description |
|----------|-------------|
| `DM_PROJECT` | Name of your `.dmprj` file |
| `CASELOG` | Name of the output log file |
| `NPROC_PER_JOB` | Number of cores allocated to each individual case |
| `NSIMULT_JOB` | Number of cases to run simultaneously |
| `PODKEY` | Your Star-CCM+ pod key (if using pod licensing) |
| `LICS` | License server address (if using a license server) |
| `LICOPT` | Comment/uncomment to switch between pod key and license server |

Make sure your total cores requested (`nodes × ppn`) is at least `NPROC_PER_JOB × NSIMULT_JOB`. For example, 4 simultaneous jobs at 96 cores each requires at least 384 cores (2 nodes).

---

## What the Script Does

**1. Setup**
The script uses `sed` to update `NumComputeProcesses` and `NumSimultaneousJobs` directly in the `.dmprj` file to match what you specified in the user inputs. It then creates a scratch folder, copies your project files over with `rsync`, and moves into the scratch directory.

**2. Execution**
Design Manager is launched using `starlaunch`, which handles distributing cases across the allocated compute nodes. It reads the node list from `$PBS_NODEFILE` and manages job placement automatically. Output is redirected to your log file and elapsed time is recorded to `stat.out`.

**3. Cleanup**
Once all cases are complete, results are copied back from scratch to your home directory and the scratch folder is removed.

---

## Script

Download or reference the full script here: [`scripts/design_manager.sh`](./scripts/design_manager.sh)

---

Next: [Vega Hardware Reference](../../cluster/vega/reference/vega_hardware.md)