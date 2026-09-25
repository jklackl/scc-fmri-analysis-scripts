# scc-fmri-analysis-scripts

A collection of scripts for fMRI data preprocessing and analysis on the University of Salzburg HPC cluster. The workflow is designed for BIDS-compliant datasets and aims to provide a relatively standardized analysis pipeline with minimal user intervention. 
The scripts leverage the cluster's computing resources to parallelize processing wherever possible and thereby reduce overall analysis time. One exception is the fMRIPrep preprocessing step: running too many subjects simultaneously can lead to race-condition issues, particularly during the FreeSurfer analysis step within fMRIPrep. To avoid this, the provided fMRIPrep script is configured to run a maximum of four subjects in parallel.
Feel free to use, modify, and adapt these scripts for your own research.

## Before You Start
- Ensure sufficient disk space. fMRIPrep outputs can easily require hundreds of GB.
- Extract your BIDS dataset (if it is compressed), e.g.:
  $ cd /mnt/ceph/groups_hdd/SCCGroup/your-group/your-study-folder/
  $ tar -xvf your-bids-dataset.tar.gz your-bids-dataset
- Install `pip` if necessary:
  $ python -m ensurepip --upgrade
- Install the containerized version of fMRIPrep:
  $ python -m pip install fmriprep-docker
- Obtain a FreeSurfer license, save it to a text file, and note its location, e.g.: /home/username/freesurfer/license.txt
- Get the BIDSPM container:
  $ git clone --recurse-submodules https://github.com/cpp-lln-lab/bidspm.git
- Place the scripts in a folder on the HPC, e.g., /mnt/ceph/groups_hdd/SCCGroup/your-group/your-study-folder/
- Edit the scripts to fit your directories and analysis needs/preferences
  
## Workflow
1. **run_1_fmriprep.sh** – Run fMRIPrep on a BIDS dataset.
2. **run_2_smooth.sh** – Smooth functional images using BIDSPM.
3. **run_3_1stlevel.sh** – Run first-level statistical analyses using BIDSPM.
Second-level analyses are currently performed manually in the SPM GUI.

## How to run the scripts
- Go to the folder in which the script is located and run them with sbatch, e.g.,
  $ sbatch run_1_fmriprep.sh
- Every now and then, check whether the jobs are actually running
  $ squeue -u your-user-name
- Every now and then, check the content of the logfiles and error logs, e.g.,
  $ cat logs/fmriprep_2630807_1_out.log
- Check the output directories for output files:
  /mnt/ceph/groups_hdd/SCCGroup/your-group/your-study-folder/your-bids-dataset/derivatives/fmriprep (output of script 1)
  /mnt/ceph/groups_hdd/SCCGroup/your-group/your-study-folder/your-bids-dataset/derivatives/bids-preproc (output of script 2)
  /mnt/ceph/groups_hdd/SCCGroup/your-group/your-study-folder/your-bids-dataset/derivatives/bids-stat (output of script 3)

## Disclaimer
These scripts were developed for my personal workflow on the University of Salzburg HPC cluster. They may contain errors. Always verify analysis settings and outputs before using them.
