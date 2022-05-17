#!/bin/csh

#SBATCH --constraint=haswell
#SBATCH --job-name=step02-modify  ## job_name
#SBATCH --account=m3780           ## project_name 
#SBATCH -q debug
#SBATCH --time=00:30:00           ## time_limit
#SBATCH --nodes=1                 ## number_of_nodes
#SBATCH --tasks-per-node=64       ## number_of_cores                                                                                              
#SBATCH --output=modify_tag.stdout1      ## job_output_filename
#SBATCH --error=modify_tag.stderr1       ## job_errors_filename

ulimit -s unlimited
module load matlab

matlab  -nodisplay -nosplash <Step_02_Modify_time_tag.m> Step_02_Modify_time_tag.log
