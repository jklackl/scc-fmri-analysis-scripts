#!/bin/bash
#SBATCH --job-name=fmriprep
#SBATCH --array=16-16 # Total number should match number of subjects (e.g., 1-20 -> subjects 1-20); try single subjects with something like '1-1'
#SBATCH --cpus-per-task=24
#SBATCH --mem=64G
#SBATCH --time=48:00:00
#SBATCH --output=logs/fmriprep_%A_%a_out.log
#SBATCH --error=logs/fmriprep_%A_%a_err.log

set -euo pipefail

SUBJECT=$(sed -n "${SLURM_ARRAY_TASK_ID}p" \
/mnt/ceph/groups_hdd/SCCGroup/social_psychology/the-prospective-brain/subjects.txt)

FMRIPREP_IMG=/home/scc_e_330386/containers/fmriprep_sandbox

BIDS_DIR=/mnt/ceph/groups_hdd/SCCGroup/social_psychology/the-prospective-brain/the-prospective-brain-main
OUT_DIR=${BIDS_DIR}/derivatives/fmriprep

FS_LICENSE=/home/scc_e_330386/freesurfer/license.txt

WORKDIR=${TMPDIR:-/tmp}/${SUBJECT}_fmriprep

mkdir -p "$WORKDIR"
trap 'rm -rf "$WORKDIR"' EXIT  # This guarantees cleanup even when a step fails.

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