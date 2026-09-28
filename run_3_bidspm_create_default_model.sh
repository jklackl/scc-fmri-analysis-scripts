#!/bin/bash
#SBATCH --job-name=bidspm_smooth
#SBATCH --array=0
#SBATCH --cpus-per-task=12
#SBATCH --mem=64G
#SBATCH --time=24:00:00
#SBATCH --output=logs/bidspm_default_model_%A_%a.out
#SBATCH --error=logs/bidspm_default_model_%A_%a.err


# Important: Remove the Transformer part of the model JSON output file before you run this script.


set -euo pipefail

mkdir -p logs

SIF="$HOME/bidspm.sif"

RAW_BIDS="/mnt/ceph/groups_hdd/SCCGroup/social_psychology/the-prospective-brain/the-prospective-brain-main"

FMRIPREP="${RAW_BIDS}/derivatives/fmriprep"

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

echo "Create default model"

apptainer exec \
  --writable-tmpfs \
  -B /mnt/ceph:/mnt/ceph \
  "$SIF" \
  bidspm \
  "$RAW_BIDS" \
  "$RAW_BIDS" \
  subject \
  default_model \
  --participant_label "$SUB" \
  --task ima \
  --space MNI152NLin2009cAsym \

echo "Finished participant ${SUB}"


