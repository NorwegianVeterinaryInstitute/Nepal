// Nepal Pipeline

// Activate dsl2
nextflow.enable.dsl=2


// Showing the basic parameters at the start of the pipeline.
// useful for catching mmissing parameters.

log.info """\
         NEPAL - Nextflow F   P I P E L I N E
         ===================================

         Workflow type running          : ${params.type}
        --------------------------------- ---------------------------------
         Input - reads                  : ${params.reads}
         Output - directory             : ${params.out_dir}
         Temporary - directory          : ${workDir}
        --------------------------------- ---------------------------------
         Nanopore flowcell              : ${params.flowcell}
         Nanopore sequencing kit        : ${params.seqkit}
         Nanopore barcode kit guppy     : ${params.guppy.barcode}
         Nanopore barcode kit           : ${params.barcode}
        --------------------------------- ---------------------------------

		 """
         .stripIndent()






// workflows

workflow BACTERIAL_ASM {
	fast5_ch=channel.fromPath(params.reads, checkIfExists: true)
                        .collect()

	GUPPY(fast5_ch)
	NANOPLOT_BASIC(GUPPY.out.summary_ch.collect())
	DUPLEX_SPLIT(GUPPY.out.fastq_ch.flatten())
	NANOFILT_BASIC(DUPLEX_SPLIT.out.demultiplexed_ch.flatten())
  FLY_BASIC(NANOFILT_BASIC.out.trimmed_ch)
}

workflow ONLY_QC {
	fast5_ch=channel.fromPath(params.reads, checkIfExists: true)
                        .collect()

	GUPPY(fast5_ch)
	NANOPLOT_BASIC(GUPPY.out.summary_ch.collect())
	QCAT(GUPPY.out.fastq_ch.collect())
	NANOFILT_BASIC(QCAT.out.demultiplexed_ch.flatten())
  FLY_BASIC(NANOFILT_BASIC.out.trimmed_ch)
}

workflow AMPLICON_RUN {
	fast5_ch=channel.fromPath(params.reads, checkIfExists: true)
                        .collect()

	GUPPY(fast5_ch)
	NANOPLOT_AMPLICON(GUPPY.out.summary_ch.collect())
	QCAT(GUPPY.out.fastq_ch.collect())
	NANOFILT_AMPLICON(QCAT.out.demultiplexed_ch.flatten())
}




// selecting the correct workflow based on user choice defined in main.config.

workflow {
if (params.type == "basic") {
	ONLY_QC()
	}

if (params.type == "amplicon") {
	AMPLICON_RUN()
	}

if (params.type == "assembly") {
	BACTERIAL_ASM()
	}
}
