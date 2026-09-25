#!/bin/bash
#SBATCH --job-name=bidspm_lvl2
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


echo "========================================="
echo "Running 2nd level stats"
echo "Host: $(hostname)"
echo "Job ID: ${SLURM_JOB_ID}"
echo "========================================="

apptainer exec \
  --writable-tmpfs \
  -B /mnt/ceph:/mnt/ceph \
  "$SIF" \
  bidspm \
  "$RAW_BIDS" \
  "$OUTPUT" \
  dataset \
  stats \
  --task ima \
  --space MNI152NLin2009cAsym \
  --model_file "$MODEL" \
  --preproc_dir "${OUTPUT}/derivatives/bidspm-preproc" \
  --fwhm 8 \

echo "========================================="
echo "DONE"
echo "========================================="
