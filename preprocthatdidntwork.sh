#!/bin/bash
## This uses a txt file with all the participant IDs. I will not lie to you the way I did it the first time was STUPID, this is the updated version but I havent run it all at once.

# Preproc sequence loop
while read ID; do
  echo "Processing subject $ID"
# Navigate to the subject directory
  cd "$ID" || { echo "Directory $ID not found! Skipping."; continue; }
# format DICOMs into mif file voxel size 2
  mrconvert DTI32/ ${ID}_vox.mif -vox 2 -coord 3 '0:1:32' -grad -export_grad_mrtrix path -export_grad_fsl bvecs_path bvals_path
# denoise images
  dwidenoise ${ID}_vox.mif v2vox.mif -noise v2_denoised.mif
# calculate residuals
  mrcalc v2_denoised.mif v2vox.mif -subtract v2_res.mif
# fsl preprocessing
  dwifslpreproc v2vox.mif ${ID}_v2preproc.mif -rpe_none -pe_dir AP -readout_time 0.1 -eddy_options " --slm=linear "
  cd ../
done < ID.txt

mkdir eddy_tempmask
while read ID; do
#this badboy is causing clipping issues PFC etc, probably due to denoising 
  dwi2mask ${ID}/${ID}_v2preproc.mif - | maskfilter - dilate - | mrconvert - eddy_tempmask/eddy_mask.nii -datatype float32 -strides -1,+2,+3 
done < ID.txt

module unload fsl
ml ants

# bias correction for all subjects which is causing contrast issues
mkdir ants
while read ID; do
    echo "Processing sucject: ${ID}"  
# this deals with the shimming. bright white areas
dwibiascorrect ${ID}/${ID}_v2preproc.mif ants/${ID}_v2preproc_unbiased.mif
cd ..
done < ID.txt

# comment
dwinormalise group ants/ eddy_tempmask/ dwi_output/ fa_template.mif fa_template_wm_mask.mif 

# eddy_afterants was done bc we need it for the poptemplate, and original eddy wasnt normalized
mkdir wmresponse
mkdir dwimask
mkdir eddy_afterants
## 
while read ID; do
    echo "Processing ID: $ID"
    dwi2response tournier dwi_output/${ID}_v2preproc_unbiased.mif wmresponse/${ID}_wm_response.txt 
    dwi2mask dwi_output/${ID}_v2preproc_unbiased.mif dwimask/${ID}_dwimask.mif 
    dwi2mask dwi_output/${ID}_v2preproc_unbiased.mif - | maskfilter - dilate - | mrconvert - eddy_afterants/${ID}_eddy_mask.nii -datatype float32 -strides -1,+2,+3 
done < ID.txt

## generate average wm response
responsemean wmresponse/*_wm_response.txt group_average_response.txt


mkdir wmfod
while read ID; do
    echo "Generating FOD: $ID"
dwi2fod csd dwi_output/${ID}_v2preproc_unbiased.mif group_average_response.txt wmfod/${ID}_wmfod.mif 
done < ID.txt
