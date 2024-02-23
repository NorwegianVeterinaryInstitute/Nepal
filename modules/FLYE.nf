// This file contains the process for the Flye assembler.


process FLY_BASIC {
	/* this process takes the output of NanoFilt and runs the Flye assembler.
	* The demultiplexed genomes are assembled with default Flye settings.
	* in the workflow this is indicated with the flatten operator.
	*/
	errorStrategy 'ignore'


	conda "/cluster/projects/nn9305k/src/miniconda/envs/flye"

	publishDir "${params.out_dir}/05_fly_asm/", pattern: "*", mode: "copy"

	label 'medium'

	input:
	tuple val(samplename), file(x)

	output:
  tuple val(samplename), path {"*"}, emit: new_assemblies

	script:
	"""
	ls -la
  flye --nano-raw *.trimmed.fastq.gz --out-dir ${samplename} --threads 8
	"""
}