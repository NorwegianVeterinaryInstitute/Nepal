// this module runs the latest version of DORADO
// Process DORADO is used for basecalling the POD5 raw data files.


process DORADO_SIMPLEX {
	conda "/cluster/projects/nn9305k/src/miniconda/envs/dorado_gpu_0.4.2"
	
	publishDir "${params.out_dir}/01_dorado_simplex/", pattern: "*", mode: "copy"
	//publishDir "${params.out_dir}/01_guppy/", pattern: "fastq", mode: "copy"
	//publishDir "${params.out_dir}/01_dorado_simplex/", pattern: "sequencing_logs/sequencing_*.*", mode: "copy"

	label 'gpu_A100'

	input:
	file("*")

	output:
	path "basecalls.bam", emit: demultiplexed_ch
	path "sequencing_summary.txt", emit: summary_ch

	script:
	"""
	dorado basecaller -x "cuda:all" --min-qscore 7 --no-trim $params.dorado.moddir/$params.dorado.model pod5 > basecalls.bam

	# creating a summary file for calculating stats
	dorado summary basecalls.bam > sequencing_summary.txt

	"""

}

// This process does demultiplexing with dorado demux.
// It takes a samplesheet and the information for the kit that was used.

process DORADO_DEMUX {
	conda "/cluster/projects/nn9305k/src/miniconda/envs/dorado_gpu_0.4.2"
	
	publishDir "${params.out_dir}/02_dorado_demux/", pattern: "demultiplexed/*", mode: "copy"
	//publishDir "${params.out_dir}/01_guppy/", pattern: "fastq", mode: "copy"
	//publishDir "${params.out_dir}/01_dorado_simplex/", pattern: "sequencing_logs/sequencing_*.*", mode: "copy"

	label 'gpu_A100'

	input:
	file(x)

	output:
	path "demultiplexed/*", emit: demultiplexed_ch

	script:
	"""
	dorado demux --kit-name $params.dorado.barcode --sample-sheet $params.samplesheet.location --output-dir demultiplexed $x

	"""

}
