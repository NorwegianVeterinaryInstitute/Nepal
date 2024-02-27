// This module runs the latest version of SAMTOOLS
// The script below will process a bam file, and extract the read_ids for the file corresponding to a read ID
// it then gives it further to dorado_duplex.

process SAMTOOLS_READIDS {
	conda "/cluster/projects/nn9305k/src/miniconda/envs/samtools_1.19.2"
	
	publishDir "${params.out_dir}/04_readid/", pattern: "*.txt", mode: "copy"
	

	input:
	file(x)

	output:
	path "*.txt", emit: readid_ch

	script:
	samplename = x.toString() - ~/.bam$/
	"""
	samtools view $x |cut -f 1 > ${samplename}.read_ids.txt

	"""

}

process SAMTOOLS_EXTRACT {
	conda "/cluster/projects/nn9305k/src/miniconda/envs/samtools_1.19.2"
	
	publishDir "${params.out_dir}/04_readid/", pattern: "*.txt", mode: "copy"
	

	input:
	file(x)

	output:
	path "*.txt", emit: readid_ch

	script:
	samplename = x.toString() - ~/.bam$/
	"""
	samtools view $x |cut -f 1 > ${samplename}.read_ids.txt

	"""

}