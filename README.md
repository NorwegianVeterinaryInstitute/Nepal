# Nepal
NExtflow Pipeline for Nanopore data anALysis 

[![DOI](https://zenodo.org/badge/296637297.svg)](https://zenodo.org/doi/10.5281/zenodo.10821960)

# Contents
* [What is NEPAL](#what-is-nepal)
* [Setting up your analysis](#setting-up-your-analysis)
* [How to run this pipeline](#how-to-run-this-pipeline)
* [Citation of Nepal](#citation-of-Nepal)
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
1. Before looking at the pipeline we will first need to look at the input data.
I store the sequence data on $USERWORK (Be sure you that this is a copy of the original data stored on NIRD).

    When you have pod5 files, then you can skip this step. 
 
    If your data is in FAST5 format, you have to convert it to pod 5. You do that by starting up the conda environment `pod5_0.3.6`. 

        conda activate pod5_0.3.6
    
    In the folder of your Nanopore run output you then run this command:

        pod5 convert fast5 -t 8 fast5/*.fast5 -o pod5 --one-to-one ./
    This will create a folder called pod5, which contains the input data for the NEPAL pipeline.

2. The next thing to do, is to create a project folder on the server where you will analyse your nanopore data. That could be the Saga cluster. For instance I created a folder in my nanopore_processing folder.

        mkdir NP_run_DATE-OF-RUN

3. Move to the new folder. Now it is time to set-up the NEPAL pipeline. You can do that in two ways.
    1. On the Saga cluster, while standing in your project folder, copy the nepal directory: 

            rsync -rauWP /cluster/projects/nn9305k/vi_src/Nepal ./

    2. Or download the repository to your project folder with the command:

            git clone https://github.com/NorwegianVeterinaryInstitute/Nepal.git 



4. In the directory Nepal that is now created, you find a comma-seperated file called: `sample_sheet.csv`. You can modify this file using nano or with a text editor such as vscode. The column for the alias is there so that the demultiplexed datasets get the names you want the sample to have. It should look like this:


        flow_cell_id,kit,experiment_id,barcode,alias
        FLO-MIN114,SQK-RBK114.24,Experiment_test,barcode01,my_first_sample
        FLO-MIN114,SQK-RBK114.24,Experiment_test,barcode02,sample02
        FLO-MIN114,SQK-RBK114.24,Experiment_test,barcode03,sample03
        FLO-MIN114,SQK-RBK114.24,Experiment_test,barcode04,sample04
        FLO-MIN114,SQK-RBK114.24,Experiment_test,barcode05,sample05
        ...

    **NOTE**: In case you only have sequenced one or a few samples with only that many barcodes from the barcoding kit, then it is possible to only write the lines for those barcodes. Dorado will not look for any other barcodes present in the dataset, and all the reads not matching the barcodes in the the sample_sheet.csv will be moved to the unclassified samples. In case you specify all 24 barcodes of a 24 barcode kit, dorado will then look for all those 24 barcodes and create the samples when it finds the barcodes.
 
5. Edit the file `main.config`,which is in the Nepal folder you just downloaded to indicate what workflow to use.
    * `simplex_assembly` - A workflow that will use all reads produced from the Nanopore machine to do an assembly with Flye.
    * `duplex_assembly` - A workflow that will try to combine forward and reverse strands into duplex reads. Note that about 5 to 10 % of your reads will be merged here. Duplex reads have in general higher qualitys than both simplex parent reads. The remaining single stranded reads will be combined with the duplex reads and together are used for assembly with Flye.
    * `amplicons`  A workflow that will use all reads produced from the Nanopore machine to do filter out the amplicon reads, and then run EMU classification against the database of your choice.


6. Edit the file `main.config`, to indicate where the data and the sample sheet are located.
7. Edit the file `main.config`, to indicate which sequencing / barcoding kit you have used, and what basecalling model you want to use. If you are unsure which model to pick, I suggest you pick the one that has "SUP" in the name, because that will give you the most accurate basecalls and the best data. If you are in a hurry, than use FAST, but you will lose more data that way.
8. Edit in the file `main.config`, the settings for Nanofilt, if you want to use different cut-off for the minimum quality or length. For Amplicons you also need to set the maximum length correctly. For full lenght 16s rRNA sequences you could use: minlenght = "1450" & maxlength = "1600". But do check that is is not discarding too many of your reads.
9. A final note. All the temporary files of the pipeline will be stored in your folder:

        $USERWORK/nepal
    The pipeline will create it, if it is not present.

# How to run this pipeline

When you have done all of the above, then you are ready to run the Nepal pipeline.
Start with creating a screen in your terminal, so you can log out of the cluster once it is running.

        screen -S NEPAL

You can always go back to the screen with

        screen -r NEPAL

Now make sure that you have set-up your conda system, because this pipeline will use the local conda environments on our cluster. 

      Hint: type `miniconda` inside the screen.

Inside the screen you can start the pipeline using the following command:
    
        ./nepal.sh main.config ../YOUR_OUTPUT_DIRECTORY

That will create a folder with the results in your project folder, next to the folder of Nepal

## Citation of Nepal
When you use this pipeline for your analysis and publication, then I would be happy if you cite the tool. You can do that by citing the DOI: `10.5281/zenodo.10821961`

## Disclaimer
This pipeline is currently in development. Contact Thomas Haverkamp for more information.

## License
This software is published under the BSD 3-clause license. See the LICENSE file in the repository.
___ 
