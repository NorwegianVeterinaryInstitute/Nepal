# Nepal
NExtflow Pipeline for 16S AmpLicons

## Disclaimer
This pipeline is currently in development. Contact Thomas Haverkamp for more information.

## License
This software is published under the BSD 3-clause license. See the LICENSE file in the repository.
___ 

# How to run this pipeline

1. Copy the following files to the directory where you want to run the analysis.
    * `main.config`
    * `nextflow.config`
    * `main.nf`
    * `nepal.sh`

2. Modify the file main.config
    * specify what kind of run you want to do: `basic`, `amplicon` or `assembly`. ( For now only `basic` works).
    * Specify the PATH where the fast5 files are located.

3. Now you can run the pipeline using the following command:
    ```
    ./nepal.sh main.config YOUR_OUTPUT_DIRECTORY
    ```


