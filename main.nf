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
        --------------------------------- ---------------------------------

		 """
         .stripIndent()

// modules for workflows

	// For ALL workflows 
	include { GUPPY_BASIC } from "${params.module_dir}/GUPPY.nf"
  	include { NANOPLOT_BASIC } from "${params.module_dir}/NANOPLOT.nf"
  	include { DUPLEX_SPLIT } from "${params.module_dir}/DUPLEXTOOLS.nf"
  	include {NANOFILT_BASIC } from "${params.module_dir}/NANOFILT.nf"
  	include {FLY_BASIC } from "${params.module_dir}/FLYE.nf"

	// Specific For workflow AMPLICON RUN
  include { NANOFILT_AMPLICON } from "${params.module_dir}/NANOFILT.nf"

// workflows

workflow BACTERIAL_ASM {
	fast5_ch=channel.fromPath(params.reads, checkIfExists: true)
                        .collect()
	GUPPY_BASIC(fast5_ch)
	NANOPLOT_BASIC(GUPPY_BASIC.out.summary_ch.collect())
	DUPLEX_SPLIT(GUPPY_BASIC.out.fastq_ch.flatten())
	NANOFILT_BASIC(DUPLEX_SPLIT.out.demultiplexed_ch.flatten())
    FLY_BASIC(NANOFILT_BASIC.out.trimmed_ch)
}

workflow ONLY_QC {
	fast5_ch=channel.fromPath(params.reads, checkIfExists: true)
                        .collect()

	GUPPY_BASIC(fast5_ch)
	NANOPLOT_BASIC(GUPPY_BASIC.out.summary_ch.collect())
	DUPLEX_SPLIT(GUPPY_BASIC.out.fastq_ch.flatten())
	NANOFILT_BASIC(QCAT.out.demultiplexed_ch.flatten())
    FLY_BASIC(NANOFILT_BASIC.out.trimmed_ch)
}

workflow AMPLICON_RUN {
	fast5_ch=channel.fromPath(params.reads, checkIfExists: true)
                        .collect()

	GUPPY_BASIC(fast5_ch)
	NANOPLOT_AMPLICON(GUPPY_BASIC.out.summary_ch.collect())
	DUPLEX_SPLIT(GUPPY_BASIC.out.fastq_ch.flatten())
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
