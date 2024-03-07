// This module runs the latest version of SAMTOOLS
// The script below will process a bam file, and extract the read_ids for the file corresponding to a read ID
// it then gives it further to dorado_duplex.

process SAMTOOLS_READIDS {
	conda "/cluster/projects/nn9305k/src/miniconda/envs/samtools_1.19.2"
	
	publishDir "${params.out_dir}/readids/", pattern: "*.txt", mode: "copy"
	
	label 'medium'

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

// the below process takes a bam file from dorado duplex,
// it then extracts the duplex reads and simplex reads


process SAMTOOLS_EXTRACT {
	conda "/cluster/projects/nn9305k/src/miniconda/envs/samtools_1.19.2"
	
	publishDir "${params.out_dir}/simplex_duplex_reads/", pattern: "*.fastq.gz", mode: "copy"
	
	label 'medium'

	input:
	file(x)

	output:
	path "*.{duplex,simplex}.fastq.gz", emit: extract_ch
	path "*.ds.fastq.gz", emit: filter_ch

	script:
	samplename = x.toString() - ~/.bam$/
	"""
	# extract duplex reads 
	samtools view -b -h -d dx:1 ${samplename}.bam > ${samplename}.duplex.bam

	# extract simplex reads from bam
	samtools view -b -h -d dx:0 ${samplename}.bam > ${samplename}.simplex.bam

	## making fastq datasets
	samtools bam2fq ${samplename}.duplex.bam > ${samplename}.duplex.fastq

	samtools bam2fq ${samplename}.simplex.bam > ${samplename}.simplex.fastq

	## the duplex files have headers with a double name, downstream analysis are stopped because of that.
	## I change the header to be one long line, by replacing the ; for an _

	##sed -i '1~4s/;.*//' ${samplename}.duplex.fastq

	pigz -9 *.fastq

	cat ${samplename}.duplex.fastq.gz ${samplename}.simplex.fastq.gz > ${samplename}.ds.fastq.gz

	"""

}