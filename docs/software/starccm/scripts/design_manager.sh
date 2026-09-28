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