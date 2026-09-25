#!/bin/bash

#SBATCH -N 4           # number of nodes (3 in this example)
#SBATCH -n 8           # number of tasks (8 tasks in this example)
#SBATCH -c 1           # number of cores-per-task (defaults to 1 if not specified)
#SBATCH -t 0-08:00:00  # time in d-hh:mm:ss
#SBATCH -p public      # partition
#SBATCH -q public      # QOS
#SBATCH -o slurm.%j.out # file to save job's STDOUT (%j = JobId)
#SBATCH -e slurm.%j.err # file to save job's STDERR (%j = JobId)
#SBATCH --mail-type=ALL # Send an e-mail when a job starts, stops, or fails
#SBATCH --mail-user="cbayouth@asu.edu"
#SBATCH --export=NONE   # Purge the job-submitting shell environment

ml mamba
source activate myENV

for ID in 10001 10002 10003 10004 10005 10006 10007 10008 10009 10010 10011 10013 10014 10015 10016 10017 10018 10019 10020 10021 10029 10036 10040 10042 10044 10046 10050 10052 10057 10059 10060 10061 10069 10076 10077 10079 10086 10088 10090 10091 10092 10093 10096 10101 10103 10106 10107 10109 10112 10113 10114 10115 10119 10124 10129 10136 10137 10147 11001 11003 11006 11007 11008 11009 11012 11013 11014 11016 11017 11019 11021 11027 11028 11030 11031 11032 11033 11038 11039 11041 11042 11044 11046 11054 11055 11056 11059 11061 11070 11071 11074 11081 11082 11084 11085 11086 11087 11088 11092; do
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
done
