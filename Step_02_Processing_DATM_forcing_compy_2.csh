#!/bin/csh

#SBATCH --job-name=step02         ## job_name
#SBATCH --partition=slurm
#SBATCH --account=esmd            ## project_name
#SBATCH --time=20:00:00           ## time_limit
#SBATCH --nodes=1                 ## number_of_nodes
#SBATCH --ntasks-per-node=1       ## number_of_cores
#SBATCH --output=step02.out       ## job_output_filename
#SBATCH --error=step02.err        ## job_errors_filename

ulimit -s unlimited
module load matlab

matlab  -nodisplay -nosplash <Step_02_Processing_DATM_forcing_2.m> Step_02_Processing_DATM_forcing_2.log
