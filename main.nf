// Nepal Pipeline

// Activate dsl2
nextflow.enable.dsl=2


// Showing the basic parameters at the start of the pipeline.
// useful for catching mmissing parameters.

log.info """\
         NEPAL - Nextflow F   P I P E L I N E
         ===================================

         Workflow type running          : ${params.type}
        --------------------------------- ---------------------------------
         Input - reads                  : ${params.reads}
         Output - directory             : ${params.out_dir}
         Temporary - directory          : ${workDir}
        --------------------------------- ---------------------------------
         Nanopore flowcell              : ${params.flowcell}
         Nanopore sequencing kit        : ${params.seqkit}
         Nanopore barcode kit           : ${params.barcode}
        --------------------------------- ---------------------------------

		 """
         .stripIndent()


// Process Guppy is used for basecalling the fast5 raw data files.
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

	guppy_basecaller --flowcell ${params.flowcell} --kit ${params.seqkit} \
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


// Nanoplot settings for the raw data when using the basic pipeline
// This will show all the reads that are coming from Guppy.
process NANOPLOT_BASIC {
	executor="local"
	conda "/cluster/projects/nn9305k/src/miniconda/envs/nanoplot"

	publishDir "${params.out_dir}/02_nanoplot_basic/", pattern: "*", mode: "copy"

	label 'tiny'

	input:
	file(summary)


	output:
	path "*.summary-plots-log-transformed"

	script:
	"""

	NanoPlot -t 4 --summary $summary --plots hex dot --title Sequencing_Summary -o Sequencing.summary-plots-log-transformed


	"""

}

//Nanoplot settings for the raw data when using the amplicon pipeline
// This will show reads with a max length of 3000 bp, longer sequences are likely not correct for amplicon sequencing.

process NANOPLOT_AMPLICON {
	conda "/cluster/projects/nn9305k/src/miniconda/envs/nanoplot"

	publishDir "${params.out_dir}/02_nanoplot_amplicon/", pattern: "*", mode: "copy"

	label 'tiny'

	input:
	file(summary)


	output:
	path "*.summary-plots-log-transformed"

	script:
	"""

	NanoPlot -t 4 --summary $summary --maxlength 3000 --plots hex dot --title Sequencing_Summary -o Sequencing.summary-plots-log-transformed


	"""

}

//Nanoplot settings for the raw data when using the amplicon pipeline
// This will show reads with a max length of 3000 bp, longer sequences are likely not correct for amplicon sequencing.

process NANOPLOT_CLEAN {
	conda "/cluster/projects/nn9305k/src/miniconda/envs/nanoplot"

	publishDir "${params.out_dir}/02_nanoplot_amplicon/", pattern: "*", mode: "copy"

	label 'tiny'

	input:
	file(barcode*.gz)


	output:
	path "*.summary-plots-log-transformed"

	script:
	"""

	NanoPlot -t 4 --fastq_minimal barcode*.gz  --maxlength 3000 --plots hex dot --title Clean_data_Summary -o Clean_data.summary-plots-log-transformed


	"""

}


process QCAT {
	// this process is to remove reads that are too short and it does demutliplexing using identified barcodes
	// the current version of qcat only uses the epi2me demultiplexing algorithm and that uses only one thread.
	// When it get's updated we might use more threads.
	// qcat is one

	conda "/cluster/projects/nn9305k/src/miniconda/envs/qcat"

	publishDir "${params.out_dir}/03_qcat/", pattern: "*", mode: "copy"

  label 'longtime'


	input:
	file(x)


	output:
	path "amplicons.demultiplexed/*", emit: demultiplexed_ch
	file("*.log")
	file("*.txt")

	script:
	"""
	zcat *.fastq.gz > all.sequences.fastq

	echo processing all.sequences.fastq

	##running qcat with default parameters
	qcat -t 1 -f all.sequences.fastq \
		-b amplicons.demultiplexed \
		--guppy \
		--kit ${params.barcode} \
		--detect-middle \
		--trim \
		--min-read-length 50  \
		--tsv > qcat_demultiplexing.log 2>stdout.log

	gzip -r amplicons.demultiplexed

	# extracting the barcode counts from stdout and put them in a parsable format
	grep -iF "barcode" stdout.log | sed -e 's/      barcode/barcode/g' | sed -e '1 ! s/  */_/g' | sed -e '1 ! s/:_|_|_/\t/g' |sed -e 's/_/\t/g' |sed -e 's/\t%//g' > barcode_counts.txt

	"""
	// need to add a way to extract for each barcode the names of the reads and then put that in a list

}

process NANOFILT_BASIC {
	/* this process is to split the output of qcat in as many processes as we have barcodes.
	* it then uses Nanofilt to process each barcoded sample seperatly
	* in the workflow this is indicated with the flatten operator.
	*/

	conda "/cluster/projects/nn9305k/src/miniconda/envs/nanofilt"

	publishDir "${params.out_dir}/04_nanofilt_basic/", pattern: "*", mode: "copy"

	label 'tiny'

	input:
	file(x)

	output:
	tuple val(samplename), path('*.trimmed.fastq.gz'), emit: trimmed_ch

	script:
	samplename = x.toString() - ~/.fastq.gz$/
	"""
	ls -la
	gunzip -c $x | NanoFilt -q 7 -l 100 --headcrop 50 | gzip > ${samplename}.trimmed.fastq.gz

	"""
}

process NANOFILT_AMPLICON {
	/* this process is to split the output of qcat in as many processes as we have barcodes.
	* it then uses Nanofilt to process each barcoded sample seperatly
	* in the workflow this is indicated with the flatten operator.
  * the minimum read length allowed is 1300 bp
  * the maxumum read length allowed is 1700 bp
  * minimum average quality score is eigth.
	*/

	conda "/cluster/projects/nn9305k/src/miniconda/envs/nanofilt"

	publishDir "${params.out_dir}/04_nanofilt_amplicon/", pattern: "*", mode: "copy"

	label 'tiny'

	input:
	file(x)

	output:
	tuple val(samplename), path('*.trimmed.fastq.gz'), emit: trimmed_ch

	script:
	samplename = x.toString() - ~/.fastq.gz$/
	"""
	ls -la
	gunzip -c $x | NanoFilt -q 7 -l 1300 --maxlength 1700 | gzip > ${samplename}.trimmed.fastq.gz

	"""
}


// workflows

workflow QUALITY_FLOW {
	fast5_ch=channel.fromPath(params.reads, checkIfExists: true)
                        .collect()

	GUPPY(fast5_ch)
	NANOPLOT_BASIC(GUPPY.out.summary_ch.collect())
	QCAT(GUPPY.out.fastq_ch.collect())
	NANOFILT_BASIC(QCAT.out.demultiplexed_ch.flatten())
}

workflow AMPLICON_RUN {
	fast5_ch=channel.fromPath(params.reads, checkIfExists: true)
                        .collect()

	GUPPY(fast5_ch)
	NANOPLOT_AMPLICON(GUPPY.out.summary_ch.collect())
	QCAT(GUPPY.out.fastq_ch.collect())
	NANOFILT_AMPLICON(QCAT.out.demultiplexed_ch.flatten())
}

workflow ASSEMBLY_RUN {
	fast5_ch=channel.fromPath(params.reads, checkIfExists: true)
                        .collect()

	GUPPY(fast5_ch)
	NANOPLOT_AMPLICON(GUPPY.out.summary_ch.collect())
	QCAT(GUPPY.out.fastq_ch.collect())
	NANOFILT_AMPLICON(QCAT.out.demultiplexed_ch.flatten())
}


// selecting the correct workflow based on user choice defined in main.config.

workflow {
if (params.type == "basic") {
	QUALITY_FLOW()
	}

if (params.type == "amplicon") {
	AMPLICON_RUN()
	}

if (params.type == "assembly") {
	ASSEMBLY_RUN()
	}
}
