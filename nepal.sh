#!/bin/bash

script_directory=$(dirname ${BASH_SOURCE[0]})

#############################################
# Check that the required Java module is loaded
#############################################
required_java_module="Java/21.0.2"

# module -t gives a terse, one-module-per-line list, safer to grep exactly
if ! module -t list 2>&1 | grep -qx "$required_java_module"; then
    echo -e "\n$required_java_module is not loaded. Loading it now...\n"
    module load "$required_java_module"

    # Confirm the load actually worked before continuing
    if ! module -t list 2>&1 | grep -qx "$required_java_module"; then
        echo -e "\nERROR: Failed to load $required_java_module. Aborting pipeline run.\n"
        exit 1
    fi
fi

echo "Using: $(java -version 2>&1 | head -n 1)"


#############################################
# Running the pipeline
#############################################

config=$1
outdir=$2
workdir=${3:-$USERWORK/nepal}

if [ ! -d "$workdir" ]; then
    mkdir "$workdir"
    echo -e "\nFolder $workdir created successfully and will be used to store temporary files! \n"
else
    echo -e ""
fi

DATE=($(date "+%Y%m%d_%R"))
mkdir -p ${outdir}/config_files
mkdir -p ${outdir}/nextflow_reports
cp ${script_directory}/main.nf ${outdir}/config_files
cp ${script_directory}/nextflow.config ${outdir}/config_files
cp ${config} ${outdir}/config_files

## running the pipeline
nextflow_25.04.7 run ${script_directory}/main.nf \
	-c ${config} \
	--out_dir=${outdir} \
	-work-dir ${workdir} \
	-resume \
	-with-report $DATE.report.html \
	-with-timeline $DATE.timeline.html \
	-with-dag $DATE.flowchart.png

# nextflow run generate *html reports describing the pipeline. Move these to output folder
mv *.html ${outdir}/nextflow_reports/
mv *.png ${outdir}/nextflow_reports/
