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
         Nanofilt quality               : ${params.quality}
         Nanofilt minlength             : ${params.minlength}
         Nanofilt maxlength             : ${params.maxlength}
        --------------------------------- ---------------------------------

		 """
         .stripIndent()
    
    // Define workflows
include { DUPLEX_ASM } from "./workflows/DUPLEX_ASM.nf"


// selecting the correct workflow based on user choice defined in main.config.

workflow {
if (params.type == "duplex_assembly") {
	DUPLEX_ASM()
	}
}
