# Star-CCM+ — Single Case

A single case run is the simplest Star-CCM+ workflow — one simulation file, one set of conditions, run to completion. Use this when you are running a single configuration or testing a setup before scaling up.

For running multiple cases or parameter sweeps, see [Design Manager](./vega-design-manager.md).

---

## Prerequisites

Before submitting, make sure you have:
- A Star-CCM+ simulation file (`.sim`)
- Any Java macros (`.java`) you want to run
- An INI file (`.ini`) if you are overriding simulation parameters at runtime
- A valid license key or license server address
- Your input files organized in your home directory

---

## Key Concepts

### Java Macros
Java macros automate actions inside Star-CCM+ such as meshing, initialization, running, and exporting results. They are passed to the solver using the `-batch` flag and can be chained together in order:

```bash
-batch changeGeometry.java,mesh,SteadyState.java,run,exportResults.java
```

Built-in macros like `mesh` and `run` do not need a file — just include them by name in the chain.

### INI Files
INI files let you override simulation parameters (e.g., angle of attack, freestream velocity) at runtime without editing the `.sim` file directly. This is useful when running the same simulation with different conditions.

Example:
```
-param AoA 5.0deg
-param freestream 50.0m/s
```

The corresponding parameters (AoA, freestream) must already be defined inside the `.sim` file for this to work.

---

## User Inputs

At the top of the script, there is a clearly marked `USER INPUTS` section. This is the only part you should need to edit for most runs:

| Variable | Description |
|----------|-------------|
| `SIM_FILE` | Name of your `.sim` file |
| `CASELOG` | Name of the output log file |
| `MACROS` | Comma-separated list of macros to run in order |
| `INI` | INI file flag and filename (leave blank if not used) |
| `PODKEY` | Your Star-CCM+ pod key (if using pod licensing) |
| `LICS` | License server address (if using a license server) |
| `LICOPT` | Comment/uncomment to switch between pod key and license server |

---

## What the Script Does

**1. Setup**
The script creates a machine file listing the allocated compute nodes, then creates a job-specific folder in scratch space using the job ID, job name, and date. Your input files are copied from your home directory to this scratch folder using `rsync`, and the script moves into that directory before doing anything else.

**2. Execution**
Star-CCM+ is launched with the number of cores allocated by the scheduler (`$PBS_NP`), the specified macros, INI file, and license options. Output is redirected to your log file. Elapsed time is calculated and written to a `stat.out` file along with cell count and core count for reference.

**3. Post-processing (optional)**
After the solver finishes, you can add additional commands to run post-processing scripts, generate plots, or convert image sequences to video. This section is clearly marked in the script.

**4. Cleanup**
Results are copied back from scratch to your home directory using `rsync`. The scratch folder is then deleted to free up space.

---

## Script

Download or reference the full script here: [`scripts/single_case.sh`](./scripts/single_case.sh)

---

Next: [Design Manager](./vega-design-manager.md)