#!/bin/csh

#SBATCH --constraint=haswell
#SBATCH --job-name=step02         ## job_name
#SBATCH --account=m3780           ## project_name 
#SBATCH -q regular
#SBATCH --time=24:00:00           ## time_limit
#SBATCH --nodes=1                 ## number_of_nodes
#SBATCH --tasks-per-node=64       ## number_of_cores                                                                                              
#SBATCH --output=mat.stdout1      ## job_output_filename
#SBATCH --error=mat.stderr1       ## job_errors_filename

ulimit -s unlimited
module load matlab

matlab  -nodisplay -nosplash <Estimate_sunrise_sunset.m> Estimate_sunrise_sunset.log
