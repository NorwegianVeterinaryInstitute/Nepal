// this file contains the different ways Nanoplot can be used.

// Nanoplot settings for the raw data when using the basic pipeline
// This will show all the reads that are coming from Guppy.
process PYCOQC_BASIC {
	executor="local"
	conda "/cluster/projects/nn9305k/src/miniconda/envs/pycoqc_2.5.2"

	publishDir "${params.out_dir}/03_basecalling_stats/", pattern: "*", mode: "copy"

	label 'tiny'

	input:
	file(summary)


	output:
	path "*.html"

	script:
	"""

	pycoQC -f $summary -o pycoQC_basecalling_stats.html


	"""

}