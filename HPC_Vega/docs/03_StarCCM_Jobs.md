# Example Star-CCM+ Job Scripts
Now that we’ve covered the basics of job submission, let’s look at two example Star-CCM+ job scripts: one for a single-case run and another for a Design Manager run.

## 1. Single Case
<details>
<summary>Single Case</summary>

<br>

A **single-case** run is the simplest Star-CCM+ workflow.  
You run one simulation file (`.sim`), typically a single configuration, geometry, or set of conditions.

**Use this when:**
- You only need one simulation.
- You’re testing or debugging a setup.

<br>
In most workflows, you’ll use Java macros (`.java` files) to control and automate your simulation.

- **Java Macros** can automate actions such as meshing, initialization, data export, or report generation. You can use Star-CCM+’s built-in macros (like `mesh` or `run`) or create custom ones. Multiple macros can be chained together and executed in order using the `-batch` flag.

Example where we run a steady-state simulation then run a transient simulation, exporting results after each:
```bash
-batch  changeGeometry.java,mesh,SteadyState.java,run,exportSS.java,Transient.java,run,exportTransient.java
```
<br>
Additionally, you can use **INI files** to set or override simulation parameters at runtime.

- **.ini files** allow you to override simulation parameters (e.g., AoA, freestream velocity, RPM) at runtime. This is useful when you want to run the same `.sim` file with different conditions without editing it directly. You must have created corresponding parameters in the `.sim` file for this to work.

Example .ini file:
```
# Parameter.ini
-param AoA 5.0deg
-param freestream 50.0m/s
-param RPM_1 800.0rpm
```

<details>
<summary>View single run script</summary>
Now let's look at an example job script for a single-case Star-CCM+ run on Vega. This script runs a simulation called `Dragonfly_Descent_withBrownout.sim`, executing several Java macros in sequence and using an INI file to set parameters. It outputs logs and statistics for analysis. The scratch space is used for performance, and results are copied back to the home directory when done.

<br>

```bash
#PBS -S /bin/bash
#PBS -q longq
#PBS -l walltime=120:00:00
#PBS -l nodes=2:ppn=192
#PBS -N DFly_Descent


###Load Modules
module purge
module use /apps/spack/share/spack/modules/linux-rocky8-zen4
module load starccm/STAR-CCM+19.04.007-R8


#################################################################
# USER INPUTS
#################################################################
# Name of simulation file to run
export SIM_FILE="Dragonfly_Descent_withBrownout.sim"

# Name of output log file
export CASELOG="sim.out"

# Define macros to run (comma-separated, no spaces)
export MACROS="aLanderGeometry.java,mesh,bSteady.java,cProcessSteady.java,dUnsteady.java,eDescent.java";

# Define ini file to use (leave blank if none)
export INI="-ini Descent.ini"
#export INI=""  # uncomment if no ini file is used

# Define license information
export PODKEY="INSERTPODKEYHERE"
export LICS=1999@insertserver.school.edu

# Comment out to use PODKEY vs. license server
export LICOPT="-power -podkey $PODKEY"
export LICOPT="-power -licpath $LICS"

export STARCCM_USE_OFFSCREEN=true
export LIBGL_ALWAYS_INDIRECT=1
#################################################################


#################################################################
# AUXILLARY COMMANDS
#################################################################
# Move to directory where job was submitted (usually in home directory)
cd $PBS_O_WORKDIR
# Create file to display compute node names for debugging purposes
mkdir machineFiles
MACHINEFILE="machineFiles/machinefile.$PBS_JOBID.txt"
cat $PBS_NODEFILE > $MACHINEFILE

# Define scratch space location
export USERNAME=$(whoami)
export SCRATCH_ROOT="/scratch/${USERNAME}"

# Define location of job execution on scratch space
export JOBID_CLEAN="${PBS_JOBID%%.*}"
export DATE_STR=$(date +"%m-%d-%y")
export SCRATCH_TASK_DIR="$SCRATCH_ROOT/${JOBID_CLEAN}_${PBS_JOBNAME}_${DATE_STR}"

# Define original job submission location
export INITIAL_SUB_DIRECTORY="$PWD"
# Create copy on scratch space then move to location
mkdir -p "$SCRATCH_TASK_DIR"
rsync -av . "$SCRATCH_TASK_DIR"
cd "$SCRATCH_TASK_DIR"
#################################################################


#################################################################
# STARCCM+ EXECUTION
#################################################################
# Calculate elapsed time
start_time=$(date)
start_timestamp=$(date -d "$start_time" +%s)

###Run Job
starccm+ -jvmargs -Xmx25G -np $PBS_NP $INI -pio -rsh ssh -graphics mesa_swr -machinefile $MACHINEFILE $LICOPT -batch $MACROS $SIM_FILE &> "$CASELOG"

# Calculate elapsed time
end_time=$(date)
end_timestamp=$(date -d "$end_time" +%s)
elapsed_time=$((end_timestamp - start_timestamp))

days=$((elapsed_time / 86400))
hours=$(( (elapsed_time % 86400) / 3600 ))
minutes=$(( (elapsed_time % 3600) / 60 ))
seconds=$((elapsed_time % 60))
formatted_elapsed_time="${days} days ${hours} hours ${minutes} minutes ${seconds} seconds"

### Report statistics
grep 'Cells:' sim.out | awk 'END {print "Number of cells: " $2}' &>>stat.out
echo "Start Time: $start_timestamp" >> stat.out
echo "End Time: $end_timestamp" >> stat.out
echo "Elapsed Time: $formatted_elapsed_time" >> stat.out
echo "Number of Cores: $PBS_NP" >> stat.out
#################################################################

#################################################################
# You can add additional post-processing commands here.
#################################################################
# Maybe your simulation export .csv files and we want to generate
# plots from them using a Python script.

# or maybe you want to convert a string of images into a video
# using ffmpeg.

# python plot_results.py results.csv results.png
# ffmpeg <options> -i image_%04d.png output_video.mp4
#################################################################

#################################################################
# CLEANUP SCRATCH SPACE
#################################################################
# Create backup file location in original directory
BACKUPFILES="$INITIAL_SUB_DIRECTORY/inputFiles"
mkdir -p "$BACKUPFILES"
mv $INITIAL_SUB_DIRECTORY/* "$BACKUPFILES"

# Move finished simulation results to original directory
rsync -av . "$INITIAL_SUB_DIRECTORY"
cd $PBS_O_WORKDIR

# Remove scratch directory results
rm -r "$SCRATCH_TASK_DIR"
#################################################################
```
</details>
</details>

---

## 2. Design Manager (multiple parallel cases)
<details>
<summary>Design Manager</summary>
<br>

**Design Manager** is used when you want to automate and manage multiple Star-CCM+ cases. For example, **parameter sweeps, design studies, or optimization**.
Instead of manually submitting each case, Design Manager coordinates and tracks them for you, managing resources, results, and post-processing.

This approach is ideal when:
- You're running multiple simulations that differ by geometry, boundary conditions, or parameters.
- You want to perform design exploration, DOE (Design of Experiments), or optimization studies.

On Vega, each Design Manager run still uses a job script like a normal case, but instead of running a single simulation, the script launches Design Manager, which then manages multiple cases within that allocation.

There are two main ways to run Design Manager on HPC systems:
1. Pre-Allocation (required for Vega):
    
    You request all needed resources upfront in the job script. Design Manager then uses these resources to run multiple cases in parallel. (If you have a local scratch space, you must use this method.)
2. General Job Submission:
    
    There are two job scripts: one for the Design Manager controller and another for the individual case runs. The controller script submits a new job for each case as previous ones finish. You are not requesting all resources upfront, but instead relying on the scheduler to allocate them as needed. (This method is not supported on Vega due to lack of local scratch space, but I will outline it [here for completeness (WIP, link broken)](link/broken).)

<details>
<summary>View Pre-Allocation Design Manager Script</summary>
<br>
This example job script demonstrates how to run a Design Manager project on Vega using the pre-allocation method. It requests the necessary resources upfront and configures Design Manager to run multiple cases in parallel. In this example, we are running a project called `DFly_AOASweep_DM.dmprj`, which is setup to perform an angle of attack sweep for the Dragonfly model. We request 2 nodes with 192 cores each (384 total) and configure Design Manager to run 4 simultaneous jobs with 96 cores each.

<br>

In this setup, there are 100 total cases defined in the Design Manager project file. Design Manager will manage running these cases in parallel, up to 4 at a time, each using 96 cores. The job script handles copying files to scratch space, executing Design Manager, and cleaning up afterward.

<br>

Take note that you must select "Linux Cluster" as the compute resource in the Design Manager project file for this to work properly. All other settings in the design manager under compute resources can be left as default. You must also already have the Design Manager project file setup and configured (this will be covered in a future section).

```bash
#PBS -S /bin/bash
#PBS -q longq
#PBS -l walltime=120:00:00
#PBS -l nodes=2:ppn=192
#PBS -N DFly_AOASweep_DM

###Load Modules
module purge
module use /apps/spack/share/spack/modules/linux-rocky8-zen4
module load starccm/STAR-CCM+19.04.007-R8

#################################################################
# USER INPUTS
#################################################################
## MAKE SURE LINUX CLUSTER IS SELECTED "COMPUTE RESOURCES" IN DMPRJ FILE

## Name of DM Project. Must be in the WORKDIR
export DM_PROJECT="DFly_AOASweep_DM.dmprj"

export CASELOG="sim.out"

## Number of processors per job
NPROC_PER_JOB=96

## Number of simultaneous jobs
NSIMULT_JOB=4

# Define license information
export PODKEY="INSERTPODKEYHERE"
export LICS=1999@insertserver.school.edu

# Comment out to use PODKEY vs. license server
export LICOPT="-power -podkey $PODKEY"
export LICOPT="-power -licpath $LICS"

export STARCCM_USE_OFFSCREEN=true
export LIBGL_ALWAYS_INDIRECT=1
#################################################################

################################################################
# AUXILLARY COMMANDS
################################################################
## Work directory. No "/" at the end.
WORKDIR=$PWD

# Set number of processors per job in DM
sed -r -i "s/'NumComputeProcesses': [0-9]+/'NumComputeProcesses': ${NPROC_PER_JOB}/" $WORKDIR/$DM_PROJECT

# Set number of simultaneous jobs in DM
sed -r -i "s/'NumSimultaneousJobs': [0-9]+/'NumSimultaneousJobs': ${NSIMULT_JOB}/" $WORKDIR/$DM_PROJECT

# Move to directory where job was submitted
cd $PBS_O_WORKDIR
# Create file to display compute node names for debugging purposes
mkdir machineFiles
MACHINEFILE="machineFiles/machinefile.$PBS_JOBID.txt"
cat $PBS_NODEFILE > $MACHINEFILE

# Define scratch space location
export USERNAME=$(whoami)
export SCRATCH_ROOT="/scratch/${USERNAME}"

# Define location of job execution on scratch space
export JOBID_CLEAN="${PBS_JOBID%%.*}"
export DATE_STR=$(date +"%m-%d-%y")
export SCRATCH_TASK_DIR="$SCRATCH_ROOT/${JOBID_CLEAN}_${PBS_JOBNAME}_${DATE_STR}"

# Define original job submission location
export INITIAL_SUB_DIRECTORY="$PWD"
# Create copy on scratch space then move to location
mkdir -p "$SCRATCH_TASK_DIR"
rsync -av --exclude=".panfs*" . "$SCRATCH_TASK_DIR"
cd "$SCRATCH_TASK_DIR"
#################################################################

#################################################################
# STARCCM+ EXECUTION
#################################################################
# Calculate elapsed time
start_time=$(date)
start_timestamp=$(date -d "$start_time" +%s)

starlaunch --rsh /usr/bin/ssh \
--command "starccm+ -rsh /usr/bin/ssh -mpi openmpi -batch run $DM_PROJECT" \
--scratch_root $SCRATCH_ROOT \
--resourcefile $PBS_NODEFILE \
--slots 0 \
--outpath $CASELOG

# Calculate elapse time
end_time=$(date)
end_timestamp=$(date -d "$end_time" +%s)
elapsed_time=$((end_timestamp - start_timestamp))

days=$((elapsed_time / 86400))
hours=$(( (elapsed_time % 86400) / 3600 ))
minutes=$(( (elapsed_time % 3600) / 60 ))
seconds=$((elapsed_time % 60))
formatted_elapsed_time="${days} days ${hours} hours ${minutes} minutes ${seconds} seconds"

echo "Start Time: $start_timestamp" >> stat.out
echo "End Time: $end_timestamp" >> stat.out
echo "Elapsed Time: $formatted_elapsed_time" >> stat.out
#################################################################

#################################################################
# CLEANUP SCRATCH SPACE
#################################################################
# Create backup file location in original directory
BACKUPFILES="$INITIAL_SUB_DIRECTORY/inputFiles"
mkdir -p "$BACKUPFILES"
mv $INITIAL_SUB_DIRECTORY/* "$BACKUPFILES"

# Move finished simulation results to original directory
rsync -av --exclude=".panfs*" . "$INITIAL_SUB_DIRECTORY"
cd $PBS_O_WORKDIR

# Remove scratch directory results
rm -r "$SCRATCH_TASK_DIR"
#################################################################
```
</details>

</details>

---
Next Topic: [Resource Planning and Performance](./04_Resource_Selection.md)