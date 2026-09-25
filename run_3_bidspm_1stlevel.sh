#!/bin/bash
#SBATCH --job-name=bidspm
#SBATCH --array=0-20
#SBATCH --cpus-per-task=12
#SBATCH --mem=64G
#SBATCH --time=24:00:00
#SBATCH --output=logs/bidspm_%A_%a.out
#SBATCH --error=logs/bidspm_%A_%a.err

set -euo pipefail

mkdir -p logs

SIF="$HOME/bidspm.sif"

RAW_BIDS="/mnt/ceph/groups_hdd/SCCGroup/social_psychology/the-prospective-brain/the-prospective-brain-main"

FMRIPREP="/mnt/ceph/groups_hdd/SCCGroup/social_psychology/the-prospective-brain/the-prospective-brain-analyze-fin"

OUTPUT="/mnt/ceph/groups_hdd/SCCGroup/social_psychology/the-prospective-brain/the-prospective-brain-vba1"

MODEL="${OUTPUT}/derivatives/models/model-defaultIma_smdl.json"

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
echo "Running participant ${SUB}"
echo "Host: $(hostname)"
echo "Job ID: ${SLURM_JOB_ID}"
echo "Array Task: ${SLURM_ARRAY_TASK_ID}"
echo "========================================="

apptainer exec \
  --writable-tmpfs \
  -B /mnt/ceph:/mnt/ceph \
  "$SIF" \
  bidspm \
  "$RAW_BIDS" \
  "$OUTPUT" \
  subject \
  stats \
  --participant_label "$SUB" \
  --task ima \
  --space MNI152NLin2009cAsym \
  --fwhm 8 \
  --preproc_dir "${OUTPUT}/derivatives/bidspm-preproc" \
  --model_file "$MODEL"

echo "========================================="
echo "DONE: ${SUB}"
echo "========================================="

#echo "========================================="
#echo "STEP 1: Smooth"
#echo "========================================="

#apptainer exec \
#  --writable-tmpfs \
#  -B /mnt/ceph:/mnt/ceph \
#  "$SIF" \
#  bidspm \
#  "$FMRIPREP" \
#  "$OUTPUT" \
#  subject \
#  smooth \
#  --participant_label 001 \
#  --task ima \
#  --space MNI152NLin2009cAsym \
#  --fwhm 8

#echo "========================================="
#echo "STEP 2: First-level GLM"
#echo "========================================="
#
#apptainer exec \
#  --writable-tmpfs \
#  -B /mnt/ceph:/mnt/ceph \
#  "$SIF" \
#  bidspm \
#  "$RAW_BIDS" \
#  "$OUTPUT" \
#  subject \
#  stats \
#  --participant_label 001 \
#  --task ima \
#  --space MNI152NLin2009cAsym \
#  --fwhm 8 \
#  --preproc_dir "${OUTPUT}/derivatives/bidspm-preproc" \
#  --model_file "$MODEL"
#
#echo "========================================="
#echo "DONE"
#echo "========================================="

