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
# using ffmpeg. The lab's animate.sh script does this in one step;
# see https://jasiatico.github.io/CFAL-Documentation/software/ffmpeg/video-scripts/

# python plot_results.py results.csv results.png
# ffmpeg <options> -i image_%04d.png output_video.mp4
# ~/scripts/animate.sh ./images ./videos
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