#!/bin/bash
#SBATCH --job-name=bidspm_smooth
#SBATCH --array=1-20
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

SMOOTH="${RAW_BIDS}/derivatives/smooth"

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
  "$FMRIPREP" \
  subject \
  smooth \
  --participant_label "$SUB" \
  --task ima \
  --space MNI152NLin2009cAsym \
  --fwhm 8

echo "Finished participant ${SUB}"


