#!/bin/bash
#SBATCH --job-name=bidspm_smooth
#SBATCH --array=0-20
#SBATCH --cpus-per-task=12
#SBATCH --mem=64G
#SBATCH --time=24:00:00
#SBATCH --output=logs/bidspm_smooth_%A_%a.out
#SBATCH --error=logs/bidspm_smooth_%A_%a.err

set -euo pipefail

mkdir -p logs

SIF="$HOME/bidspm.sif"

RAW_BIDS="/mnt/ceph/groups_hdd/SCCGroup/social_psychology/the-prospective-brain/the-prospective-brain-main"

FMRIPREP="${RAW_BIDS}/derivatives/fmriprep"

# By default, this script puts the smoothed data into a parallel derivative in the main BIDS folder (i.e., a folder called bidspm-preproc next to the original fmriprep folder). 
# If you want things to be nested (i.e., a BIDS folder in a BIDS folder in a BIDS folder etc.), change the output folder to e.g., SMOOTH (see below).

# To declutter, I run 
# rm /mnt/ceph/groups_hdd/SCCGroup/social_psychology/the-prospective-brain/the-prospective-brain-main/derivatives/bidspm-preproc/sub-0*/ses-0*/func/sub-0*_ses-0*_task-ima_space-MNI152NLin2009cAsym_desc-preproc_bold.* # to remove the doubled non-smoothed, preprocessed data in the bidspm-preproc folder
# rm -r /mnt/ceph/groups_hdd/SCCGroup/social_psychology/the-prospective-brain/the-prospective-brain-main/derivatives/bidspm-preproc/sub-0*/anat # to remove the anat smoothed and unsmoothed anat files in the bidspm-preproc folder

SMOOTH="${RAW_BIDS}/derivatives/bidspm_smooth"

PARTICIPANTS=(
001
002
003
004
005
006
007
008
009
010
011
012
013
014
015
016
017
018
019
020
021
)

SUB=${PARTICIPANTS[$SLURM_ARRAY_TASK_ID]}

echo "========================================="
echo "Participant: ${SUB}"
echo "========================================="

echo "SMOOTH"

apptainer exec \
  --writable-tmpfs \
  -B /mnt/ceph:/mnt/ceph \
  "$SIF" \
  bidspm \
  "$FMRIPREP" \
  "$RAW_BIDS" \
  subject \
  smooth \
  --participant_label "$SUB" \
  --task ima \
  --space MNI152NLin2009cAsym \
  --fwhm 8

echo "Finished participant ${SUB}"


