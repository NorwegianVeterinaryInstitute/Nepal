// PhyloFlow Pipeline

// Activate dsl2
nextflow.enable.dsl=2

// describe the processes that are part of the pipeline
process GUPPY {
	conda "/cluster/projects/nn9305k/src/miniconda/envs/guppy_gpu_v4"
	publishDir "${params.out_dir}/01_guppy/", pattern: "logs/guppy_basecaller_*.log", mode: "copy"
	publishDir "${params.out_dir}/01_guppy/", pattern: "fastq/*.gz", mode: "copy"
	publishDir "${params.out_dir}/01_guppy/", pattern: "sequencing_logs/sequencing_*.*", mode: "copy"

	label 'gpu'

	input:
	file("*") 


	output:
	path "fastq/*.gz", emit: fastq_ch
	file("logs/guppy_basecaller_*.log")
	path "sequencing_logs/sequencing_summary.txt", emit: summary_ch

	script:
	"""
	
	guppy_basecaller --flowcell FLO-MIN106 --kit SQK-RBK004 \
        -x "cuda:all" \
        --gpu_runners_per_device 16 \
        --num_callers 16 \
    --records_per_fastq 0 \
    --compress_fastq \
    -i fast5 \
    -s fastq

	# moving log files
	mkdir logs
	mv fastq/guppy_basecaller_*.log logs/

	# moving sequencing telemetry and summary files
	mkdir sequencing_logs
	mv fastq/sequencing_*.* sequencing_logs/

	"""
}

process NANOPLOT {
	conda "/cluster/projects/nn9305k/src/miniconda/envs/nanoplot"

	publishDir "${params.out_dir}/02_nanoplot/", pattern: "*", mode: "copy"

	label 'shorttime'

	input:
	file(summary) 


	output:
	path "*.summary-plots-log-transformed"

	script:
	"""
	 
	NanoPlot -t 4 --summary $summary --maxlength 3000 --plots hex dot --title Sequencing_Summary -o Sequencing.summary-plots-log-transformed


	"""


}

/*
process QCAT {
	conda "/cluster/projects/nn9305k/src/miniconda/envs/qcat"

	publishDir "${params.out_dir}/03_qcat/", pattern: "*", mode: "copy"

	input:
	file(x) 


	output:
	path "*.summary-plots-log-transformed"

	script:
	"""
	ls -la
	 
	qcat

	##moving data to $SCRATCH
cd $SCRATCH

rsync -r $FASTQ_DIR/*.fastq.gz $SCRATCH/

gunzip -v *.gz

cat *.fastq > all.sequences.fastq

#create output dir ID for demultiplexed reads
MYDATA=(16SrRNA_reads)


echo processing all.sequences.fastq

##running qcat with default parameters
qcat -t 10 -f all.sequences.fastq -b $MYDATA.demultiplexed \
    --kit NBD103/NBD104 --detect-middle --trim --min-read-length 50  --tsv

# checking output
ls -la

#moving data back to project area

rsync -rauWP $MYDATA.demultiplexed $OUTPUT_DIR
rsync -rauWP *.tsv $OUTPUT_DIR



	"""
*/






// workflows

workflow QUALITY_FLOW {
	fast5_ch=channel.fromPath(params.reads, checkIfExists: true)
                        .collect()

	GUPPY(fast5_ch)
	NANOPLOT(GUPPY.out.summary_ch.collect())
	//QCAT(GUPPY.out.fastq_ch.collect())
}


// selecting the correct workflow based on user choice defined in main.config.

workflow {
if (params.type == "basic") {
	QUALITY_FLOW()
	}

if (params.type == "amplicon") {
	PARSNP_PHYLO()
	}

if (params.type == "assembly") {
	CORE_PHYLO()
	}
}
