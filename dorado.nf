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
         Nanopore barcode kit Dorado     : ${params.dorado.barcode}
        --------------------------------- ---------------------------------

		 """
         .stripIndent()

// modules for workflows

// modules for workflows

	// For ALL workflows 
	include { DORADO_SIMPLEX } from "${params.module_dir}/DORADO.nf"
  	

	

// workflows

workflow SIMPLEX_ASM {
	pod5_ch=channel.fromPath(params.reads, checkIfExists: true)
                        .collect()

	DORADO_SIMPLEX(pod5_ch)
	//NANOPLOT_BASIC(GUPPY_BASIC.out.summary_ch.collect())
	//DUPLEX_SPLIT(GUPPY_BASIC.out.fastq_ch.flatten())
	//NANOFILT_BASIC(QCAT.out.demultiplexed_ch.flatten())
    //FLY_BASIC(NANOFILT_BASIC.out.trimmed_ch)