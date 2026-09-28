#!/bin/bash
#SBATCH --job-name=fmriprep
#SBATCH --array=0-20%4
#SBATCH --cpus-per-task=24 # IMPORTANT: Adjust #SBATCH --array=0-(N-1) whenever subjects are added or removed.
#SBATCH --mem=64G
#SBATCH --time=48:00:00
#SBATCH --output=logs/fmriprep_%A_%a_out.log
#SBATCH --error=logs/fmriprep_%A_%a_err.log

set -euo pipefail

# ==========================================
# Edit this list as needed
# ==========================================
SUBJECTS=(
sub-001
sub-002
sub-003
sub-004
sub-005
sub-006
sub-007
sub-008
sub-009
sub-010
sub-011
sub-012
sub-013
sub-014
sub-015
sub-016 # uncomment and reduce array size if needed 
sub-017
sub-018
sub-019
sub-020
sub-021
)

SUBJECT=${SUBJECTS[$SLURM_ARRAY_TASK_ID]}

if [ "$SLURM_ARRAY_TASK_ID" -ge "${#SUBJECTS[@]}" ]; then
    echo "Error: SLURM_ARRAY_TASK_ID=$SLURM_ARRAY_TASK_ID exceeds subject list length (${#SUBJECTS[@]})."
    exit 1
fi

echo "Running subject: $SUBJECT"

FMRIPREP_IMG=/home/scc_e_330386/containers/fmriprep_sandbox

BIDS_DIR=/mnt/ceph/groups_hdd/SCCGroup/social_psychology/the-prospective-brain/the-prospective-brain-main
OUT_DIR=${BIDS_DIR}/derivatives/fmriprep

FS_LICENSE=/home/scc_e_330386/freesurfer/license.txt

WORKDIR=${TMPDIR:-/tmp}/${SUBJECT}_fmriprep

mkdir -p "$WORKDIR"
trap 'rm -rf "$WORKDIR"' EXIT

mkdir -p "$OUT_DIR"

apptainer exec \
    --cleanenv \
    -B ${BIDS_DIR}:/bids \
    -B ${OUT_DIR}:/out \
    -B ${WORKDIR}:/work \
    -B ${FS_LICENSE}:/license.txt \
    ${FMRIPREP_IMG} \
    fmriprep \
    /bids \
    /out \
    participant \
    --participant-label ${SUBJECT#sub-} \
    --output-spaces MNI152NLin2009cAsym \
    --fs-license-file /license.txt \
    --nprocs 24 \
    --omp-nthreads 2 \
    --mem 60000 \
    -w /work

rm -rf "$WORKDIR"