# Job Submission

This page covers everything you need to actually run a job on Vega — writing a job script, submitting it, and monitoring it once it's running.

---

## 1. The Job Script

To run anything on Vega, you need a **job script** — a bash script that tells the scheduler what resources to request and what commands to run. The scheduler reads this file, queues your job, and executes it on a compute node when resources are available.

Here is a minimal example:

```bash
#!/bin/bash
#PBS -N my_job               # Job name
#PBS -q longq                # Queue
#PBS -l nodes=2:ppn=192      # 2 nodes, 192 cores each (384 total)
#PBS -l walltime=02:00:00    # Max runtime (HH:MM:SS)

# Load software
module load starccm/STAR-CCM+20.04.008-R8

# Run your program
starccm+ -np $PBS_NP -batch run my_simulation.sim
```

Submit it with:

```bash
msub my_job_script.sh
```

---

## 2. PBS Directives

Lines beginning with `#PBS` are **directives** — instructions to the scheduler that must appear at the top of the script, before any executable commands. The only exception is the shebang (`#!/bin/bash`), which always comes first.

> [!TIP]
> **What is a shebang?**
> The `#!/bin/bash` line tells the system to interpret the script using the bash shell. Different shells (e.g., `zsh`, `tcsh`, `ksh`) have different syntax, and a script written for bash may not behave correctly in another shell. Always include this line.

### Common Directives

For a full reference of all available directives, see [Job Script Directives](../reference/job_script_directives.md).

| Directive | Description | Example |
|-----------|-------------|---------|
| `-N` | Job name | `-N LES_Scramjet` |
| `-q` | Queue to submit to | `-q longq` |
| `-l nodes=#:ppn=#` | Nodes and cores per node | `-l nodes=2:ppn=192` |
| `-l mem=#gb` | Total memory | `-l mem=16gb` |
| `-l walltime=HH:MM:SS` | Maximum runtime | `-l walltime=02:00:00` |
| `-o <file>` | Standard output file | `-o my_job.log` |
| `-e <file>` | Standard error file | `-e my_job_error.log` |
| `-j oe` | Merge output and error into one file | `-j oe` |
| `-M <email>` | Email for notifications | `-M user@domain.com` |
| `-m <option>` | When to send emails (`b`egin, `e`nd, `a`bort) | `-m bea` |

---

## 3. Available Resources and Limits

Vega has 42 compute nodes, each with 192 cores and 1.5 TB RAM. To ensure fair usage across all users, the following limits apply:

| Limit | Value |
|-------|-------|
| Max nodes per user | 4 nodes (768 cores) |
| Max walltime per job | 5 days (`longq`) |
| Max queued jobs per user | 4 additional jobs |

### Queues

Vega has three queues. Jobs in shorter queues are generally prioritized over longer ones, and jobs requesting fewer resources are prioritized over larger ones.

| Queue | Max Walltime |
|-------|-------------|
| `shortq` | 2 hours |
| `mediumq` | 1 day |
| `longq` | 5 days |

**Important walltime notes:**
- Jobs that exceed their walltime are terminated automatically with no warning (meaning your progress will be lost).
- Always request slightly more time than you expect — but not excessively, as it affects your queue priority.
- Directives like walltime and node count cannot be changed after submission. If you need to adjust them, cancel the job and resubmit.

---

## 4. Workflow: Home → Scratch → Run → Copy Back

As covered in [Vega Basics](./03_vega_basics.md), all jobs should run from scratch space, not your home directory. Running from `/home2` causes significant file I/O slowdowns for large simulations.

A typical workflow looks like this:

1. Keep your input files organized in `/home2/<yourusername>/`, e.g.:
    ```
    /home2/<yourusername>/LES_Airfoils/LES_NACA0012_AOA10/
    ```
2. In your job script, create a corresponding folder in scratch:
    ```
    /scratch/<yourusername>/<jobid>_<jobname>_<date>/
    ```
3. Copy input files from home to scratch using `rsync`.
4. Change into the scratch directory and run your job.
5. After completion, copy results back to your home directory.
6. Clean up the scratch folder to free space.

This pattern is already built into the example job scripts in the [Star-CCM+ section](../../../software/starccm/vega-single-case.md).

---

## 5. Monitoring and Managing Jobs

### Check your jobs

```bash
qstat
```

Example output:

```
Job ID                         Name                User            Time Use  S Queue
------------------------------ ------------------- --------------- --------- - -----
12345.vegabk.head.cm.vega.era  my_simulation_job   username        00:10:00  R longq
```

The `S` column shows job status: `R` = running, `Q` = queued, `C` = completed.

### Other useful commands

```bash
# View the full job queue (all users)
showq

# View detailed info for a specific job
qstat -f 12345

# Cancel a job
canceljob 12345
```

Use `canceljob` if a job is misconfigured, no longer needed, or stuck. It terminates immediately without saving progress.

---

## 6. PBS Environment Variables

When the scheduler runs your job, it automatically sets a number of environment variables you can use inside your script. For a full list, see [Job Script Directives](../reference/job_script_directives.md).

The most commonly used ones:

| Variable | Description |
|----------|-------------|
| `$PBS_NP` | Total number of cores allocated to the job |
| `$PBS_NUM_NODES` | Number of nodes allocated |
| `$PBS_NUM_PPN` | Cores per node |
| `$PBS_JOBID` | The job ID assigned by TORQUE |
| `$PBS_JOBNAME` | The job name |
| `$PBS_NODEFILE` | Path to a file listing all allocated compute nodes |
| `$PBS_O_WORKDIR` | Directory from which the job was submitted |
| `$PBS_O_HOME` | Home directory of the submitting user |
| `$PBS_QUEUE` | Queue the job is running in |

These can be useful when creating more complex job scripts that need to adapt based on the allocated resources or when you want to automate file naming and organization based on job parameters. For example, in my job script, I use `$PBS_JOBID` to create a unique scratch folder for each job or I use `$PBS_NP` to specify the number of processes for my Star-CCM+ run to avoid hardcoding it.

---

Next: [GPU Computing](./06_gpu_computing.md)