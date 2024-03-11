// modules for DUPLEX_ASM workflow
	
    include { DORADO_DEMUX } from "../modules/DORADO.nf"
    include { DORADO_SIMPLEX } from "../modules/DORADO.nf"
    include { NANOFILT_SIMPLEX } from "../modules/NANOFILT.nf"
  	include { NANOPLOT_SIMPLEX } from "../modules/NANOPLOT.nf"
    include { NANOPLOT_FASTQ } from "../modules/NANOPLOT.nf"
    include { PYCOQC_SIMPLEX } from "../modules/PYCOQC.nf"
    include { SAMTOOLS_BAM2FQ } from "../modules/SAMTOOLS.nf"
    include { SEQKIT_SIMPLEX } from "../modules/SEQKIT.nf"
    include { SEQKIT_NFILT } from "../modules/SEQKIT.nf"
    include { SEQKIT_FLYE } from "../modules/SEQKIT.nf"
    include { FLYE_ASM } from "../modules/FLYE.nf"


// workflows

workflow SIMPLEX_ASM {
	pod5_ch=channel.fromPath(params.reads, checkIfExists: true)
                        .collect()

    // process reads to get demultiplexed reads IDs
	DORADO_SIMPLEX(pod5_ch)   
    DORADO_DEMUX(DORADO_SIMPLEX.out.simplex_ch.flatten())
    // process reads to get duplex and simplex reads
    SAMTOOLS_BAM2FQ(DORADO_DEMUX.out.demux_ch.flatten())

    // filtering the reads to remove poor reads
    NANOFILT_SIMPLEX(SAMTOOLS_BAM2FQ.out.filter_ch.flatten())

    // Doing an assembly with FLYE on all samples
    FLYE_ASM(NANOFILT_SIMPLEX.out.nfilt_ch.flatten())

    // Generating the stats of the sequence data
	NANOPLOT_SIMPLEX(DORADO_SIMPLEX.out.summary_ch.collect())
    PYCOQC_SIMPLEX(DORADO_SIMPLEX.out.summary_ch.collect())
    NANOPLOT_FASTQ(SAMTOOLS_BAM2FQ.out.filter_ch.flatten())
    SEQKIT_SIMPLEX(SAMTOOLS_BAM2FQ.out.filter_ch.flatten())
    SEQKIT_NFILT(NANOFILT_SIMPLEX.out.nfilt_ch.collect())
    SEQKIT_FLYE(FLYE_ASM.out.assembly_ch.flatten())
    
}
