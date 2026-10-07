#!/bin/bash

#SBATCH -N 1           # number of nodes (3 in this example)
#SBATCH -c 2           # number of cores-per-task (defaults to 1 if not specified)
#SBATCH -a 1-99        # number of jobs in array (i think)    
#SBATCH -t 0-00:20:00  # time in d-hh:mm:ss
#SBATCH -p public      # partition
#SBATCH -q public      # QOS
#SBATCH -o Output/slurm.%j.out # file to save job's STDOUT (%j = JobId)
#SBATCH -e Output/slurm.%j.err # file to save job's STDERR (%j = JobId)
#SBATCH --mail-type=ALL # Send an e-mail when a job starts, stops, or fails
#SBATCH --mail-user="$u@asu.edu"
#SBATCH --export=NONE   # Purge the job-submitting shell environment

ml mamba
source activate myENV
ml ants

readonly manifest="with_v2" 
readonly ID=$(getline $SLURM_ARRAY_TASK_ID "$manifest")

## create mask and dialate it, then preform ants bias correction
for n in 01 02 03 04 05 06; do
        SES_DIR="sub-${ID}/ses-${n}"
        # skip if the session directory doesn't exist
        if [[ ! -d "$SES_DIR" ]]; then
            echo "-- Skipping sub-${ID} ses-${n} (no session directory)"
            continue
        fi
dwi2mask "${SES_DIR}/step2_fsl.mif" "${SES_DIR}/step3.1_tempmask.mif" 
maskfilter "${SES_DIR}/step3.1_tempmask.mif" dilate "${SES_DIR}/step3.2_dialatemask.mif" 
dwibiascorrect ants "${SES_DIR}/step2_fsl.mif"  "${SES_DIR}/step3.3_ants.mif"
    done
