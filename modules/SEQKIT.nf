// Settings for the analysis of fastq.gz files extracted by samtools with SEQKIT
// This will generate a table that gives a small overview of the simplex and duplex reads for each sample
process SEQKIT_STATS {
	executor="local"
	conda "/cluster/projects/nn9305k/src/miniconda/envs/seqkit_2.7.0"

	publishDir "${params.out_dir}/03_basecalling_stats/", pattern: "*", mode: "copy"

	label 'medium'

	input:
	file(x)


	output:
	path "*.txt"

	script:
	"""
	seqkit stats -j 8 *.duplex.fastq.gz --all -T > duplex_stats.txt
	
	seqkit stats -j 8 *.simplex.fastq.gz --all -T > simplex_stats.txt

	cat duplex_stats.txt simplex_stats.txt > duplex_simplex_stats.txt

	rm -r duplex_stats simplex_stats.txt

	"""


}

process SEQKIT_NFILT {
	executor="local"
	conda "/cluster/projects/nn9305k/src/miniconda/envs/seqkit_2.7.0"

	publishDir "${params.out_dir}/03_basecalling_stats/", pattern: "*", mode: "copy"

	label 'medium'

	input:
	file(x)


	output:
	path "*.txt"

	script:
	"""
	seqkit stats -j 8 *.fastq.gz --all -T > Nanofilt_out_stats.txt

	"""


}