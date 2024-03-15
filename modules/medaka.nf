// This file contains the process for the Flye assembler.


process MEDAKA {
	/* this process takes the output of FLYE and runs the MEDAKA to polish the assembly.
	* The demultiplexed genomes are assembled with default Flye settings.
	* in the workflow this is indicated with the flatten operator.
	*/
	errorStrategy 'ignore'


	conda "/cluster/projects/nn9305k/src/miniconda/envs/medaka_1.9.1"

	publishDir "${params.out_dir}/medaka_asm/", pattern: "*", mode: "copy"

	label 'heavy'

	input:
	tuple val(samplename), file(np_reads), file(assembly)

	output:
	file("*")
  tuple val(samplename), path {"*"}, emit: medaka_ch

	script:
	"""
	ls -la
    flye --nano-raw *.nfilt.fastq.gz --out-dir ${samplename} --threads 20
	"""
}



process MEDAKA_basic {
	conda (params.enable_conda ? 'bioconda::medaka=1.8.0' : null)
	container 'quay.io/biocontainers/medaka:1.8.0--py38hdaa7744_0'

        input:
        tuple val(datasetID), file(np_reads), file(assembly)

        output:
        file("*")
	tuple val(datasetID) file("consensus.fasta"), emit: medaka_ch

        """
	medaka_consensus -i $np_reads -d $assembly -m $params.basecalling_model -t $task.cpus -o .
	"""
}