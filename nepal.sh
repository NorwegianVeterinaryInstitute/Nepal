#!/bin/bash

script_directory=$(dirname ${BASH_SOURCE[0]})

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
cp ${config} ${outdir}/config_files

## running the pipeline
nextflow_23.10.1 run ${script_directory}/main.nf \
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