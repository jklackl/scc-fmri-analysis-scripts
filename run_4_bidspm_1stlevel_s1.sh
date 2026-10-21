#!/bin/bash
#SBATCH --job-name=bidspm
#SBATCH --array=0-20
#SBATCH --cpus-per-task=12
#SBATCH --mem=64G
#SBATCH --time=24:00:00
#SBATCH --output=logs/bidspm_1stlevel_%A_%a.out
#SBATCH --error=logs/bidspm_1stlevel_%A_%a.err

set -euo pipefail

mkdir -p logs

SIF="$HOME/bidspm.sif"

RAW_BIDS="/mnt/ceph/groups_hdd/SCCGroup/social_psychology/the-prospective-brain/the-prospective-brain-main"

MODEL="${RAW_BIDS}/derivatives/models/model-ima-s1.json"


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


echo "========================================="
echo "1ST LEVEL STATISTICS"
echo "========================================="

apptainer exec \
  --writable-tmpfs \
  -B /mnt/ceph:/mnt/ceph \
  "$SIF" \
  bidspm \
  "$RAW_BIDS" \
  "$RAW_BIDS" \
  subject \
  stats \
  --participant_label "$SUB" \
  --task ima \
  --space MNI152NLin2009cAsym \
  --fwhm 8 \
  --preproc_dir "${RAW_BIDS}/derivatives/bidspm-preproc" \
  --model_file "$MODEL"

echo "========================================="
echo "CONTRASTS"
echo "========================================="

apptainer exec \
  --writable-tmpfs \
  -B /mnt/ceph:/mnt/ceph \
  "$SIF" \
  bidspm \
  "$RAW_BIDS" \
  "$RAW_BIDS" \
  subject \
  contrasts \
  --participant_label "$SUB" \
  --task ima \
  --space MNI152NLin2009cAsym \
  --fwhm 8 \
  --preproc_dir "${RAW_BIDS}/derivatives/bidspm-preproc" \
  --model_file "$MODEL"

echo "========================================="
echo "FOLDER RENAMING"
echo "========================================="


MODEL_BASENAME=$(basename "$MODEL" .json)

STATS_DIR="${RAW_BIDS}/derivatives/bidspm-stats"
SUB_DIR="${STATS_DIR}/sub-${SUB}"

OLD_NAME="task-ima_space-MNI152NLin2009cAsym_FWHM-8"
NEW_NAME="ima-s1"

if [ -d "${SUB_DIR}/${OLD_NAME}" ] && [ ! -d "${SUB_DIR}/${NEW_NAME}" ]; then
    mv "${SUB_DIR}/${OLD_NAME}" "${SUB_DIR}/${NEW_NAME}"
fi


echo "========================================="
echo "DONE: ${SUB}"
echo "========================================="
