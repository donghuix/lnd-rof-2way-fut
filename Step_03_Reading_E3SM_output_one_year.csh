#!/bin/csh

#SBATCH --job-name=step03         ## job_name
#SBATCH --partition=slurm
#SBATCH --account=esmd            ## project_name
#SBATCH --time=20:00:00           ## time_limit
#SBATCH --nodes=1                 ## number_of_nodes
#SBATCH --ntasks-per-node=1       ## number_of_cores
#SBATCH --output=step03.out       ## job_output_filename
#SBATCH --error=step03.err        ## job_errors_filename

ulimit -s unlimited
module load matlab

matlab  -nodisplay -nosplash <Step_03_Reading_E3SM_output_one_year.m> Step_03_Reading_E3SM_output_one_year.log
