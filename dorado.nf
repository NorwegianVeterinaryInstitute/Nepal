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
         Nanopore barcode kit Dorado    : ${params.dorado.barcode}
         Dorado model directory         : ${params.dorado.moddir}
         Dorado model selected          : ${params.dorado.model}
        --------------------------------- ---------------------------------

		 """
         .stripIndent()

// modules for workflows

	// For ALL workflows 
	include { DORADO_SIMPLEX } from "${params.module_dir}/DORADO.nf"
    include { DORADO_DEMUX } from "${params.module_dir}/DORADO.nf"
  	include { NANOPLOT_SIMPLEX } from "${params.module_dir}/NANOPLOT.nf"
    include { PYCOQC_SIMPLEX } from "${params.module_dir}/PYCOQC.nf"

	

// workflows

workflow SIMPLEX_ASM {
	pod5_ch=channel.fromPath(params.reads, checkIfExists: true)
                        .collect()

	DORADO_SIMPLEX(pod5_ch)
	NANOPLOT_SIMPLEX(DORADO_SIMPLEX.out.summary_ch.collect())
    PYCOQC_SIMPLEX(DORADO_SIMPLEX.out.summary_ch.collect())
    DORADO_DEMUX(DORADO_SIMPLEX.out.demultiplexed_ch.collect())
	//DUPLEX_SPLIT(GUPPY_BASIC.out.fastq_ch.flatten())
	//NANOFILT_BASIC(QCAT.out.demultiplexed_ch.flatten())
    //FLY_BASIC(NANOFILT_BASIC.out.trimmed_ch)
}

// selecting the correct workflow based on user choice defined in main.config.

workflow {
if (params.type == "assembly") {
	SIMPLEX_ASM()
	}
}
