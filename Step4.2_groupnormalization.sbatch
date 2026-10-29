#!/bin/bash

#SBATCH -N 1           # number of nodes (3 in this example)
#SBATCH -c 8           # number of cores-per-task (defaults to 1 if not specified)   
#SBATCH -t 0-20:00:00  # time in d-hh:mm:ss
#SBATCH -p public      # partition
#SBATCH -q public      # QOS
#SBATCH -o output/slurm.%j.out # file to save job's STDOUT (%j = JobId)
#SBATCH -e output/slurm.%j.err # file to save job's STDERR (%j = JobId)
#SBATCH --mail-type=ALL # Send an e-mail when a job starts, stops, or fails
#SBATCH --mail-user="$u@asu.edu"
#SBATCH --export=NONE   # Purge the job-submitting shell environment

ml mamba
source activate myENV
ml ants

dwinormalise group dwinormalise/dwi_input/ dwinormalise/mask_input/ dwinormalise/dwi_output/ dwinormalise/fa_template.mif dwinormalise/fa_template_wm_mask.mif

## check the scale factors applied during normalization. Make sure mean scale factors are the same between groups, if not it might bias AFD analysis.
mrinfo ../dwinormalise/dwi_output/* -property dwi_norm_scale_factor > scalefactor.txt

