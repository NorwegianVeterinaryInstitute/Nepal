// modules for DUPLEX_ASM workflow
	
    include { DORADO_DEMUX } from "../modules/DORADO.nf"
    include { DORADO_DUPLEX } from "../modules/DORADO.nf"
    include { DORADO_SIMPLEX } from "../modules/DORADO.nf"
    include { NANOFILT_DUPLEX } from "../modules/NANOFILT.nf"
  	include { NANOPLOT_SIMPLEX } from "../modules/NANOPLOT.nf"
	include { NANOPLOT_DUPLEX } from "../modules/NANOPLOT.nf"
    include { NANOPLOT_FASTQ } from "../modules/NANOPLOT.nf"
    include { PYCOQC_SIMPLEX } from "../modules/PYCOQC.nf"
    include { SAMTOOLS_EXTRACT } from "../modules/SAMTOOLS.nf"
    include { SAMTOOLS_READIDS } from "../modules/SAMTOOLS.nf"
    include { SEQKIT_DUPLEX } from "../modules/SEQKIT.nf"
    include { SEQKIT_NFILT } from "../modules/SEQKIT.nf"
    include { SEQKIT_FLYE } from "../modules/SEQKIT.nf"
    include { FLYE_ASM } from "../modules/FLYE.nf"


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
    NANOFILT_DUPLEX(SAMTOOLS_EXTRACT.out.filter_ch.flatten())

    // Doing an assembly with FLYE on all samples
    FLYE_ASM(NANOFILT_DUPLEX.out.nfilt_ch.flatten())

    // Generating the stats of the sequence data
	NANOPLOT_SIMPLEX(DORADO_SIMPLEX.out.summary_ch.collect())
    PYCOQC_SIMPLEX(DORADO_SIMPLEX.out.summary_ch.collect())
    NANOPLOT_DUPLEX(SAMTOOLS_EXTRACT.out.extract_ch.collect())
    SEQKIT_DUPLEX(SAMTOOLS_EXTRACT.out.extract_ch.collect())
    SEQKIT_NFILT(NANOFILT_DUPLEX.out.nfilt_ch.collect())
    SEQKIT_FLYE(FLYE_ASM.out.assembly_ch.flatten())
    
    
	//DUPLEX_SPLIT(GUPPY_BASIC.out.fastq_ch.flatten())
	//NANOFILT_BASIC(QCAT.out.demultiplexed_ch.flatten())
    //FLY_BASIC(NANOFILT_BASIC.out.trimmed_ch)
}
