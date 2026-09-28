# SCC fMRI easy analysis scripts

A collection of scripts for fMRI data preprocessing and analysis on the University of Salzburg HPC cluster. The workflow is designed for BIDS-compliant datasets and aims to provide a relatively standardized analysis pipeline with minimal user intervention. 
The scripts leverage the cluster's computing resources to parallelize processing wherever possible and thereby reduce overall analysis time. One exception is the fMRIPrep preprocessing step: running too many subjects simultaneously can lead to race-condition issues, particularly during the FreeSurfer analysis step within fMRIPrep. To avoid this, the provided fMRIPrep script is configured to run a maximum of four subjects in parallel.
Feel free to use, modify, and adapt these scripts for your own research.

These scripts use fMRIPrep and BIDSPM.
fMRIPrep is a standardized preprocessing pipeline for functional MRI (fMRI) data. It takes raw (f)MRI data in BIDS format and automatically performs the major processing steps required before statistical analysis, such as correcting for head motion, aligning functional and anatomical images, removing non-brain tissue, segmenting different tissue types, and transforming the data into a standard brain space.
BIDSPM is a framework that combines the Brain Imaging Data Structure (BIDS) with the statistical analysis tools provided by SPM (Statistical Parametric Mapping). While fMRIPrep focuses on preparing raw MRI data for analysis, BIDSPM focuses on organizing, running, and documenting the actual analyses. It can automatically find the appropriate files, construct first-level and second-level models, run analyses in SPM, and store the results in a structured and reproducible manner. This reduces the amount of manual scripting that is often required in traditional SPM workflows.
The scripts presented here provide a way to use fMRIPrep and BIDSPM on datasets. fMRIPrep produces preprocessed fMRI data, and BIDSPM then uses those data to perform tasks such as spatial smoothing, model specification, parameter estimation, contrast estimation, and subject-level and group-level analyses. 

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
3. **run_3_create_default_model.sh** – Create a model JSON file for statistical analysis.
4. **run_4_bidspm_1stlevel.sh** – Run first-level statistical analyses using BIDSPM.
5. **run_5_bidspm_2ndlevel.sh** – Run second-level statistical analyses using BIDSPM.

## How to run the scripts
- Go to the folder in which the script is located
- Edit the scripts and adapt them to your project. Think of paths, subject numbers, your desired smoothing kernel, etc.
- Run the scripts using, e.g.,
  $ sbatch run_1_fmriprep.sh
- You may run several or all subjects in parallel, but keep in mind that for every subject, you must follow the sequence (i.e., you can only smooth after fmriprep)
- Every now and then, check whether the jobs are actually running
  $ squeue -u your-user-name
- Every now and then, check the content of the logfiles and error logs, e.g.,
  $ cat logs/fmriprep_2630807_1_out.log
- Check the output directories for output files:
  /mnt/ceph/groups_hdd/SCCGroup/your-group/your-study-folder/your-bids-dataset/derivatives/fmriprep (output of script 1)
  /mnt/ceph/groups_hdd/SCCGroup/your-group/your-study-folder/your-bids-dataset/derivatives/bids-preproc (output of script 2)
  /mnt/ceph/groups_hdd/SCCGroup/social_psychology/the-prospective-brain/the-prospective-brain-main/derivatives/models/model-default<task>_smdl.json (output of script 3)
  /mnt/ceph/groups_hdd/SCCGroup/your-group/your-study-folder/your-bids-dataset/derivatives/bidspm-stats (output of script 4)
- Make sure to edit the model json file that results from step/script 3 according to your needs (e.g., define the conditions and contrasts)

## Disclaimer
These scripts were developed for my personal workflow on the University of Salzburg HPC cluster. They may contain errors. Always verify analysis settings and outputs before using them.
