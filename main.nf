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
         Nanfilt quality                : ${params.quality}
         Nanfilt minlength              : ${params.minlength}
         Nanfilt maxlength              : ${params.maxlength}
        --------------------------------- ---------------------------------

		 """
         .stripIndent()

// modules for workflows

	// For ALL workflows 
	
    include { DORADO_DEMUX } from "${params.module_dir}/DORADO.nf"
    include { DORADO_DUPLEX } from "${params.module_dir}/DORADO.nf"
    include { DORADO_SIMPLEX } from "${params.module_dir}/DORADO.nf"
    include { NANOFILT } from "${params.module_dir}/NANOFILT.nf"
  	include { NANOPLOT_SIMPLEX } from "${params.module_dir}/NANOPLOT.nf"
    include { NANOPLOT_FASTQ } from "${params.module_dir}/NANOPLOT.nf"
    include { PYCOQC_SIMPLEX } from "${params.module_dir}/PYCOQC.nf"
    include { SAMTOOLS_EXTRACT } from "${params.module_dir}/SAMTOOLS.nf"
    include { SAMTOOLS_READIDS } from "${params.module_dir}/SAMTOOLS.nf"
    include { SEQKIT_STATS } from "${params.module_dir}/SEQKIT.nf"
    include { SEQKIT_NFILT } from "${params.module_dir}/SEQKIT.nf"
    include { SEQKIT_FLYE } from "${params.module_dir}/SEQKIT.nf"
    include { FLYE_DUPLEX } from "${params.module_dir}/FLYE.nf"
    
    
	

// workflows

workflow DUPLEX_ASM {
	pod5_ch=channel.fromPath(params.reads, checkIfExists: true)
                        .collect()

    // process reads to get demultiplexed reads IDs
	DORADO_SIMPLEX(pod5_ch)   
    DORADO_DEMUX(DORADO_SIMPLEX.out.simplex_ch.flatten())
    SAMTOOLS_READIDS(DORADO_DEMUX.out.demux_ch.flatten())
    // process reads to get duplex and simplex reads
    DORADO_DUPLEX(pod5_ch.combine(SAMTOOLS_READIDS.out.readid_ch))
    SAMTOOLS_EXTRACT(DORADO_DUPLEX.out.duplex_ch.flatten())

    // filtering the reads to remove poor reads
    NANOFILT(SAMTOOLS_EXTRACT.out.filter_ch.flatten())

    // Doing an assembly with FLYE on all samples
    FLYE_DUPLEX(NANOFILT_DUPLEX.out.nfilt_ch.flatten())

    // Generating the stats of the sequence data
	NANOPLOT_SIMPLEX(DORADO_SIMPLEX.out.summary_ch.collect())
    PYCOQC_SIMPLEX(DORADO_SIMPLEX.out.summary_ch.collect())
    NANOPLOT_FASTQ(SAMTOOLS_EXTRACT.out.extract_ch.collect())
    SEQKIT_STATS(SAMTOOLS_EXTRACT.out.extract_ch.collect())
    SEQKIT_NFILT(NANOFILT_DUPLEX.out.nfilt_ch.collect())
    SEQKIT_FLYE(FLYE_DUPLEX.out.assembly_ch.flatten())
    
    
	//DUPLEX_SPLIT(GUPPY_BASIC.out.fastq_ch.flatten())
	//NANOFILT_BASIC(QCAT.out.demultiplexed_ch.flatten())
    //FLY_BASIC(NANOFILT_BASIC.out.trimmed_ch)
}

// selecting the correct workflow based on user choice defined in main.config.

workflow {
if (params.type == "duplex_assembly") {
	DUPLEX_ASM()
	}
}
