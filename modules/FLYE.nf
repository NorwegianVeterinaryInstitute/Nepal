// This file contains the process for the Flye assembler.


process FLY_BASIC {
	/* this process takes the output of NanoFilt and runs the Flye assembler.
	* The demultiplexed genomes are assembled with default Flye settings.
	* in the workflow this is indicated with the flatten operator.
	*/
	errorStrategy 'ignore'


	conda "/cluster/projects/nn9305k/src/miniconda/envs/flye"

	publishDir "${params.out_dir}/flye_asm/", pattern: "*", mode: "copy"

	label 'heavy'

	input:
	tuple val(samplename), file(x)

	output:
  tuple val(samplename), path {"*"}, emit: new_assemblies

	script:
	"""
	ls -la
    flye --nano-raw *.nfilt.fastq.gz --out-dir ${samplename} --threads 20
	"""
}

process FLYE_ASM {
	/* this process takes the output of NanoFilt and runs the Flye assembler.
	* The demultiplexed genomes are assembled with default Flye settings.
	* in the workflow this is indicated with the flatten operator.
	*/
	errorStrategy 'ignore'


	conda "/cluster/projects/nn9305k/src/miniconda/envs/flye"

	publishDir "${params.out_dir}/flye_asm/", pattern: "*", mode: "copy"

	label 'heavy'

	input:
	//tuple val(samplename), file(x)
	file(x)

	output:
	tuple val(samplename), path {"*"}
	path {"*.flye.asm.fasta"}, emit: assembly_ch

	script:
	samplename = x.toString() - ~/.nfilt.fastq.gz$/
	"""
	ls -la
  	flye --nano-raw *.fastq.gz --out-dir ${samplename} --threads 20

    ln -s ${samplename}/assembly.fasta ./${samplename}.flye.asm.fasta

	"""
}
