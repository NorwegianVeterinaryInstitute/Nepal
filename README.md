# Nepal
NExtflow Pipeline for Nanopore data anALysis

# Contents
* [What is NEPAL](#what-is-nepal)
* [Setting up your analysis](#setting-up-your-analysis)
* [How to run this pipeline](#how-to-run-this-pipeline)
* [Disclaimer](#disclaimer)
* [License](#license)

# What is Nepal?
Nepal is a pipeline for processing raw nanopore data and can be used for sequence data for bacterial genomes, 16s rRNA or just generate a clean demultiplexed dataset that can be used in other projects. The pipeline is set-up for usage on a HPC cluster that uses slurm for task management. It requires the use of servers with GPUs (Nivdia A100) for the basecalling step. It can be run locally, if one or more GPUs are available. This pipeline takes as input a folder with pod5 files (https://pod5-file-format.readthedocs.io/en/latest/index.html), a samplesheet, the basecalling model you want to use, and the ID for the sequencing / barcoding kit you have you used.

The current tools that are included in the pipeline are:
* Basecalling: 
    * Dorado 
* Vizualize read quality: 
    * Nanoplot
    * pycoQC
* Quality control and filtering: 
    * Nanofilt
* Bacterial Genome assembly:
    * Flye
* Fastq read stats and genome stats:
    * Seqkit


# Setting up your analysis
1. Prepare your input data. If your data is in FAST5 format, you have to convert it to pod 5. You do that by starting up the conda environment `pod5_0.3.6`. 

        conda activate pod5_0.3.6
    
    In the folder of your Nanopore run output you then run this command:

        pod5 convert fast5 -t 8 fast5/*.fast5 -o pod5 --one-to-one ./
    This will create a folder called pod5, which contains the input data for the NEPAL pipeline

2. In the directory Nepal that is now created, you find a comma-seperated file called: `sample_sheet.csv`. You can modify this file using nano or with a text editor such as vscode. The column for the alias is there so that the demultiplexed datasets get the names you want the sample to have. It should look like this:


        flow_cell_id,kit,experiment_id,barcode,alias
        FLO-MIN114,SQK-RBK114.24,Experiment_test,barcode01,my_first_sample
        FLO-MIN114,SQK-RBK114.24,Experiment_test,barcode02,sample02
        FLO-MIN114,SQK-RBK114.24,Experiment_test,barcode03,sample03
        FLO-MIN114,SQK-RBK114.24,Experiment_test,barcode04,sample04
        FLO-MIN114,SQK-RBK114.24,Experiment_test,barcode05,sample05
        ...


3. Now download this repository to your project folder with the command:

        git clone https://github.com/NorwegianVeterinaryInstitute/Nepal.git 

4. Edit the file `main.config`,which is in the Nepal folder you just downloaded to indicate what workflow to use.
    * `simplex_assembly` - A workflow that will use all reads produced from the Nanopore machine to do an assembly with Flye.
    * `duplex_assembly` - A workflow that will try to combine forward and reverse strands into duplex reads. Note that about 10 % of your reads will be merged here. Duplex reads have in general higher qualitys than both simplex parent reads. The remaining single stranded reads will be combined with the duplex reads and together are used for assembly with Flye.
    * `amplicons`  A workflow that will use all reads produced from the Nanopore machine to do filter out the amplicon reads, and then run EMU classification against the database of your choice.

5. Edit the file `main.config`, to indicate where the data, the sample sheet are located.
6. Edit the file `main.config`, to indicate which sequencing / barcoding kit you have used, and what basecalling model you want to use. If you are unsure which model to pick, I suggest you pick the one that has "SUP" in the name, because that will give you the most accurate basecalls and the best data. If you are in a hurry, than use FAST, but you will lose more data that way.
7. Edit in the file `main.config`, the settings for Nanofilt, if you want to use different cut-off for the minimum quality or length. For Amplicons you also need to set the maximum length correctly. For full lenght 16s rRNA sequences you could use: minlenght = "1450" & maxlength = "1600". But do check that is is not discarding too many of your reads.
8. A final note. All the temporary files of the pipeline will be stored in your folder:

        $USERWORK/nepal
    The pipeline will create it, if it is not present.

# How to run this pipeline

When you have done all of the above, then you are ready to run the Nepal pipeline.
Start with created a screen in your terminal, so you can log out of the cluster once it is running.

        screen -S NEPAL

You can always go back to the screen with

        screen -r NEPAL

Make sure that you have set-up your conda system, because this pipeline will use the local conda environments on our cluster. Hint: type `miniconda` inside the screen.

Inside the screen you can start the pipeline using the following command:
    
        ./nepal.sh main.config ../YOUR_OUTPUT_DIRECTORY

That will create a folder with the results in your project folder, next to the folder of Nepal

## Disclaimer
This pipeline is currently in development. Contact Thomas Haverkamp for more information.

## License
This software is published under the BSD 3-clause license. See the LICENSE file in the repository.
___ 
