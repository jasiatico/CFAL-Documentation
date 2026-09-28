# Job Script Directives Reference

This page is a full reference for PBS directives and environment variables used in Vega job scripts. For a practical introduction to job submission, see [Job Submission](../getting-started/05_job_submission.md).

---

## PBS Directives

Directives are placed at the top of your job script, after the shebang (`#!/bin/bash`) and before any executable commands. Each line must begin with `#PBS`.

| Directive | Description | Example |
|-----------|-------------|---------|
| `-N` | Job name | `-N LES_Scramjet` |
| `-q` | Queue to submit to | `-q longq` |
| `-l nodes=#:ppn=#` | Number of nodes and cores per node | `-l nodes=2:ppn=192` |
| `-l mem=#gb` | Total memory requested | `-l mem=16gb` |
| `-l walltime=HH:MM:SS` | Maximum runtime | `-l walltime=02:00:00` |
| `-o <file>` | File to write standard output | `-o my_job.log` |
| `-e <file>` | File to write standard error | `-e my_job_error.log` |
| `-j oe` | Merge standard output and error into one file | `-j oe` |
| `-M <email>` | Email address for notifications | `-M user@domain.com` |
| `-m <option>` | When to send email: `b`egin, `e`nd, `a`bort, `n`one | `-m bea` |
| `-A <account>` | Billing or project account | `-A my_project` |
| `-l gpus=#` | Number of GPUs to request (GPU nodes only) | `-l nodes=1:ppn=192:gpus=4` |

---

## PBS Environment Variables

When the scheduler runs your job, it automatically sets the following environment variables. These can be referenced anywhere in your job script.

| Variable | Description |
|----------|-------------|
| `$PBS_NP` | Total number of cores allocated to the job |
| `$PBS_NUM_NODES` | Number of nodes allocated |
| `$PBS_NUM_PPN` | Number of cores per node |
| `$PBS_JOBID` | Job ID assigned by TORQUE (e.g., `12345.vegabk.head.cm.vega.era`) |
| `$PBS_JOBNAME` | Job name as set by `-N` |
| `$PBS_QUEUE` | Queue the job is running in |
| `$PBS_NODEFILE` | Path to a file listing all allocated compute node hostnames |
| `$PBS_GPUFILE` | Path to a file listing allocated GPUs (GPU jobs only) |
| `$PBS_O_WORKDIR` | Directory from which the job was submitted |
| `$PBS_O_HOME` | Home directory of the submitting user |
| `$PBS_O_HOST` | Hostname of the node running the job |