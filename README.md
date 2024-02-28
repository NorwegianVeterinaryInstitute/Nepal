# Nepal
NExtflow Pipeline for Nanopore data anALysis

## Disclaimer
This pipeline is currently in development. Contact Thomas Haverkamp for more information.

## License
This software is published under the BSD 3-clause license. See the LICENSE file in the repository.
___ 

# What is Nepal?
Nepal is a pipeline for processing raw nanopore data and can be used for sequence data for bacterial genomes, 16s rRNA or just generate a clean demultiplexed dataset that can be used in other projects. The pipeline is set-up for usage on a HPC cluster that uses slurm for task management. It requires the use of servers with GPUs (Nivdia A100) for the basecalling step. It can be run locally, if one or more GPUs are available. This pipeline takes as input a folder with pod5 files (https://pod5-file-format.readthedocs.io/en/latest/index.html) and a samplesheet.

The current tools that are included in the pipeline are:
* Basecalling: Dorado version xxx
* Vizualize read quality: Nanoplot XXX
* Quality control and filtering: Nanofilt
* Bacterial Genome assembly: Flye

# Setting up your analysis
1. Download this repository to your project folder with the command:
    `https://github.com/NorwegianVeterinaryInstitute/Nepal.git`.
2. In the directory Nepal that is now created, you find a file called: `sample_sheet.csv`. You can modify this file using nano or with a text editor such as vscode, so that multiplex datasets get the right names. 
3. You also need to modify the fill `main.config`, so that the basecaller you select `dorado` or `guppy` uses the right model, the correct sequencing / barcode kit that was used.  


# How to run this pipeline

1. Copy the following files to the directory where you want to run the analysis.
    * `main.config`
    * `nextflow.config`
    * `main.nf`
    * `nepal.sh`

2. Modify the file main.config
    * specify what kind of run you want to do: `basic`, `amplicon` or `assembly`. ( For now only `basic` works).
    * Specify the PATH where the fast5 files are located.
    * Specify the flowcell you used
    * Specify the sequencing kit you used
    * Specify the barcode kit you used

3. Now you can run the pipeline using the following command:
    ```
    ./nepal.sh main.config YOUR_OUTPUT_DIRECTORY
    ```


