// this module runs the latest version of GUPPY.

// Process Guppy is used for basecalling the fast5 raw data files.
process DORADO_SIMPLEX {
	conda "/cluster/projects/nn9305k/src/miniconda/envs/dorado_gpu_0.4.2"
	publishDir "${params.out_dir}/01_dorado_simplex/", pattern: "logs/guppy_basecaller_*.log", mode: "copy"
	//publishDir "${params.out_dir}/01_guppy/", pattern: "fastq", mode: "copy"
	publishDir "${params.out_dir}/01_dorado_simplex/", pattern: "sequencing_logs/sequencing_*.*", mode: "copy"

	label 'gpu_A100'

	input:
	file("*")

	output:
	path "basecalls.bam", emit summary_ch,demultiplex_ch 
	//path "fastq/pass/barcode*", emit: fastq_ch
	//path "fastq"
	//file("logs/guppy_basecaller_*.log")
	//path "sequencing_logs/sequencing_summary.txt", emit: summary_ch

	script:
	"""
	dorado basecaller -x "cuda:all" --min-qscore 7 --no-trim --emit-fastq $params.dorado.moddir/$params.dorado.model pod5 > basecalls.bam

	"""
}