#!/bin/bash

#SBATCH -N 1           # number of nodes (3 in this example)
#SBATCH -c 2           # number of cores-per-task (defaults to 1 if not specified)
#SBATCH --mem=85GB     # memory nbetween cores
#SBATCH -a 1-99        # number of jobs in array (i think)    
#SBATCH -t 0-01:00:00  # time in d-hh:mm:ss
#SBATCH -p public      # partition
#SBATCH -q public      # QOS
#SBATCH -o slurm.%j.out # file to save job's STDOUT (%j = JobId)
#SBATCH -e slurm.%j.err # file to save job's STDERR (%j = JobId)
#SBATCH --mail-type=ALL # Send an e-mail when a job starts, stops, or fails
#SBATCH --mail-user="$u@asu.edu"
#SBATCH --export=NONE   # Purge the job-submitting shell environment

ml mamba
source activate myENV

readonly manifest="with_v2" 
readonly ID=$(getline $SLURM_ARRAY_TASK_ID "$manifest")

    for n in 01 02 03 04 05 06; do
        SES_DIR="sub-${ID}/ses-${n}"
        # skip if the session directory doesn't exist
        if [[ ! -d "$SES_DIR" ]]; then
            echo "-- Skipping sub-${ID} ses-${n} (no session directory)"
            continue
        fi
        echo ">> Converting sub-${ID} ses-${n}"
        mrconvert "${SES_DIR}"/*/ "${SES_DIR}/dwi.mif" -vox 2 -coord 3 '0:1:32'
        echo ">> Denoising and Giibs sub-${ID} ses-${n} - Step 1"
        dwidenoise "${SES_DIR}/dwi.mif"  "${SES_DIR}/step1_denoised.mif"
        mrdegibbs "${SES_DIR}/step1_denoised.mif" "${SES_DIR}/step1_unringed.mif"         

    done

