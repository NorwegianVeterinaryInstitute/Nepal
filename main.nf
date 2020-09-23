// PhyloFlow Pipeline

// Activate dsl2
nextflow.enable.dsl=2

// Processes
process GUPPY {
	conda "/cluster/projects/nn9305k/src/miniconda/envs/guppy_gpu_v4"
	publishDir "${params.out_dir}/01_guppy/logs", pattern: "fastq/guppy_basecaller_*.log", mode: "copy"
	publishDir "${params.out_dir}/01_guppy/fastq", pattern: "fastq/*.gz", mode: "copy"
	publishDir "${params.out_dir}/01_guppy/sequencing_logs", pattern: "fastq/sequencing_*.*", mode: "copy"


	input:
	file("*")

	output:
	path "fastq/*.gz", emit: fastq_ch
	file("fastq/guppy_basecaller_*.log")
	file("fastq/sequencing_summary.txt")
	file("fastq/sequencing_telemetry.js")

	script:
	"""
	guppy_basecaller --flowcell FLO-MIN106 --kit SQK-RBK004 \
        -x "cuda:all" \
        --gpu_runners_per_device 16 \
        --num_callers 16 \
    --records_per_fastq 0 \
    --compress_fastq \
    -i fast5 \
    -s fastq

	"""
}



// workflows

workflow QUALITY_FLOW {
	reads_ch=channel.fromPath(params.reads, checkIfExists: true)
                        .collect()

	GUPPY(reads_ch)
}


/*
workflow PARSNP_PHYLO {
	assemblies_ch=channel.fromPath(params.assemblies, checkIfExists: true)
			     .collect()

	PARSNP(assemblies_ch)
	CONVERT(PARSNP.out.xmfa_ch)
	if (params.deduplicate) {
		DEDUPLICATE(CONVERT.out.fasta_alignment_ch)
		GUBBINS(DEDUPLICATE.out.seqkit_ch)
		MASKRC(GUBBINS.out.gubbins_ch,
		       DEDUPLICATE.out.seqkit_ch)
	}
	if (!params.deduplicate) {
		GUBBINS(CONVERT.out.fasta_alignment_ch)
		MASKRC(GUBBINS.out.gubbins_ch,
		       CONVERT.out.fasta_alignment_ch)
	}
	SNPDIST(MASKRC.out.masked_ch)
	IQTREE(MASKRC.out.masked_ch)
}


workflow SNIPPY_PHYLO {
	reads_ch=channel.fromPath(params.reads, checkIfExists: true)
                        .collect()

        SNIPPY(reads_ch)
	if (params.deduplicate) {
                DEDUPLICATE(SNIPPY.out.snippy_alignment_ch)
                GUBBINS(DEDUPLICATE.out.seqkit_ch)
		MASKRC(GUBBINS.out.gubbins_ch,
		       DEDUPLICATE.out.seqkit_ch)
        }
        if (!params.deduplicate) {
                GUBBINS(SNIPPY.out.snippy_alignment_ch)
		MASKRC(GUBBINS.out.gubbins_ch,
		       SNIPPY.out.snippy_alignment_ch)
        }
        SNPDIST(MASKRC.out.masked_ch)
        IQTREE(MASKRC.out.masked_ch)
}
*/


workflow {
if (params.type == "basic") {
	QUALITY_FLOW()
	}

if (params.type == "amplicon") {
	PARSNP_PHYLO()
	}

if (params.type == "assembly") {
	CORE_PHYLO()
	}
}
