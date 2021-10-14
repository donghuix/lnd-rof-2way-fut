#!/bin/csh

#SBATCH --constraint=haswell
#SBATCH --job-name=step_01              ## job_name
#SBATCH --account=m3780                 ## project_name
#SBATCH --time=20:00:00
#SBATCH -q regular
#SBATCH --nodes=1                       ## number_of_nodes
#SBATCH --tasks-per-node=64             ## number_of_cores
#SBATCH --output=mat.stdout1            ## job_output_filename
#SBATCH --error=mat.stderr1             ## job_errors_filename

ulimit -s unlimited

module load matlab

matlab  -nodisplay -nosplash <Step_01_Downloading_ATM_forcing.m> Step_01_Downloading_ATM_forcing.log
