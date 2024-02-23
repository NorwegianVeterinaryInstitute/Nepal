// this file contains the tools duplex reads which creates a workflow for guppy.

process DUPLEX_SPLIT {
	// process to split the demultiplexed reads into simplex reads
	// this will split reads if they contain an internal barcode
	conda "/cluster/projects/nn9305k/src/miniconda/envs/guppy_gpu_v6.5.7"

	publishDir "${params.out_dir}/02_simplex_reads/", pattern: "*", mode: "copy"

	//label 'medium'  // duplex tools needs only cpus

	input:
	file(x)

	output:
	path "simplex.*", emit: demultiplexed_ch


	script:
	"""
	echo folder to process $x

	duplex_tools split_on_adapter --threads 8 $x simplex.$x Native

	"""



}