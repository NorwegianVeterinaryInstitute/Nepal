// this file contains the different ways Nanoplot can be used.

// Nanoplot settings for the raw data when using the basic pipeline
// This will show all the reads that are coming from Guppy.
process NANOPLOT_BASIC {
	executor="local"
	conda "/cluster/projects/nn9305k/src/miniconda/envs/nanoplot"

	publishDir "${params.out_dir}/03_basecalling_stats/", pattern: "*", mode: "copy"

	label 'tiny'

	input:
	file(summary)


	output:
	path "*-plots-log-transformed"

	script:
	"""

	NanoPlot -t 4 --summary $summary --plots hex dot --title Sequencing_Summary -o Nanoplot-plots-log-transformed


	"""

}

//Nanoplot settings for the raw data when using the amplicon pipeline
// This will show reads with a max length of 3000 bp, longer sequences are likely not correct for amplicon sequencing.

process NANOPLOT_AMPLICON {
	conda "/cluster/projects/nn9305k/src/miniconda/envs/nanoplot"

	publishDir "${params.out_dir}/03_basecalling_stats/", pattern: "*", mode: "copy"

	label 'tiny'

	input:
	file(summary)


	output:
	path "*-plots-log-transformed"

	script:
	"""

	NanoPlot -t 4 --summary $summary --maxlength 3000 --plots hex dot --title Sequencing_Summary -o NanoPlot-plots-log-transformed


	"""

}

//Nanoplot settings for the raw data when using the amplicon pipeline
// This will show reads with a max length of 3000 bp, longer sequences are likely not correct for amplicon sequencing.

process NANOPLOT_CLEAN {
	conda "/cluster/projects/nn9305k/src/miniconda/envs/nanoplot"

	publishDir "${params.out_dir}/03_basecalling_stats/", pattern: "*", mode: "copy"

	label 'tiny'

	input:
	file(barcode*.gz)


	output:
	path "*-plots-log-transformed"

	script:
	"""

	NanoPlot -t 4 --fastq_minimal barcode*.gz --plots hex dot --title Clean_data_Summary -o NanoPlot-plots-log-transformed


	"""

}
