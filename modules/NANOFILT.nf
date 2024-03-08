process NANOFILT_DUPLEX {
	// this file contains the process that is used by Nanofilt
	
	/* it then uses Nanofilt to process each barcoded sample seperatly
	* in the workflow this is indicated with the flatten operator.
	*/

	conda "/cluster/projects/nn9305k/src/miniconda/envs/nanofilt_2.8.0"

	publishDir "${params.out_dir}/nanofilt_reads/", pattern: "*", mode: "copy"

	label 'tiny'

	input:
	file(x)

	output:
	//tuple val(samplename), path('*nfilt.fastq.gz'), emit: nfilt_ch
	path('*nfilt.fastq.gz'), emit: nfilt_ch

	script:
	samplename = x.toString() - ~/.ds.fastq.gz$/
	"""
	ls -la
	gunzip -c *.gz | NanoFilt -q $params.quality -l $params.minlength --maxlength $params.maxlength | gzip > ${samplename}.nfilt.fastq.gz

	"""
}


process NANOFILT_SIMPLEX {
	// this file contains the process that is used by Nanofilt
	
	/* it then uses Nanofilt to process each barcoded sample seperatly
	* in the workflow this is indicated with the flatten operator.
	*/

	conda "/cluster/projects/nn9305k/src/miniconda/envs/nanofilt_2.8.0"

	publishDir "${params.out_dir}/nanofilt_reads/", pattern: "*", mode: "copy"

	label 'tiny'

	input:
	file(x)

	output:
	//tuple val(samplename), path('*nfilt.fastq.gz'), emit: nfilt_ch
	path('*.nfilt.fastq.gz'), emit: nfilt_ch

	script:
	samplename = x.toString() - ~/.simplex.fastq.gz$/
	"""
	ls -la
	gunzip -c *.gz | NanoFilt -q $params.quality -l $params.minlength --maxlength $params.maxlength | gzip > ${samplename}.nfilt.fastq.gz

	"""
}