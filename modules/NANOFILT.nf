process NANOFILT_BASIC {
	// this file contains the process that are used by Nanofilt
	
	/* this process is to split the output of qcat in as many processes as we have barcodes.
	* it then uses Nanofilt to process each barcoded sample seperatly
	* in the workflow this is indicated with the flatten operator.
	*/

	conda "/cluster/projects/nn9305k/src/miniconda/envs/nanofilt_2.8.0"

	publishDir "${params.out_dir}/04_nanofilt_basic/", pattern: "*", mode: "copy"

	label 'tiny'

	input:
	file(x)

	output:
	tuple val(samplename), path('*.NFilt.fastq.gz'), emit: trimmed_ch

	script:
	samplename = x.toString() - ~/.fastq.gz$/
	"""
	ls -la
	gunzip -c $x/*.gz | NanoFilt -q 7 -l 300 | gzip > ${samplename}.NFilt.fastq.gz

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

	conda "/cluster/projects/nn9305k/src/miniconda/envs/nanofilt_2.8.0"

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

process NANOFILT_DUPLEX {
	// this file contains the process that are used by Nanofilt
	
	/* this process is to split the output of qcat in as many processes as we have barcodes.
	* it then uses Nanofilt to process each barcoded sample seperatly
	* in the workflow this is indicated with the flatten operator.
	*/

	conda "/cluster/projects/nn9305k/src/miniconda/envs/nanofilt_2.8.0"

	publishDir "${params.out_dir}/04_nanofilt_basic/", pattern: "*", mode: "copy"

	label 'tiny'

	input:
	file(x)

	output:
	tuple val(samplename), path('*nfilt.fastq.gz'), emit: nfilt_ch

	script:
	samplename = x.toString() - ~/.ds.fastq.gz$/
	"""
	ls -la
	gunzip -c *.gz | NanoFilt -q 7 -l 300 | gzip > ${samplename}.nfilt.fastq.gz

	"""
}