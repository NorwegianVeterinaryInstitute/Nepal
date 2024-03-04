// this file contains the different ways Nanoplot can be used.

// Nanoplot settings for the raw data when using the basic pipeline
// This will show all the reads that are coming from Guppy.
process PYCOQC_BASIC {
	executor="local"
	conda "/cluster/projects/nn9305k/src/miniconda/envs/pycoqc_2.5.2"

	publishDir "${params.out_dir}/data_overview/", pattern: "*", mode: "copy"

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


// Nanoplot settings for the raw data when using the basic pipeline
// This will show all the reads that are coming from dorado simplex.
process PYCOQC_SIMPLEX {
	executor="local"
	conda "/cluster/projects/nn9305k/src/miniconda/envs/pycoqc_2.5.2"

	publishDir "${params.out_dir}/data_overview/", pattern: "*", mode: "copy"

	label 'tiny'

	input:
	file(summary)


	output:
	path "*.html"

	script:
	"""

	pycoQC -q -f $summary -o pycoQC_basecalling_stats.html


	"""
}