// this module runs the latest version of GUPPY.

// Process Guppy is used for basecalling the fast5 raw data files.
process GUPPY_BASIC {
	conda "/cluster/projects/nn9305k/src/miniconda/envs/guppy_gpu_v6.5.7"
	publishDir "${params.out_dir}/guppy_output/", pattern: "logs/guppy_basecaller_*.log", mode: "copy"
	//publishDir "${params.out_dir}/01_guppy/", pattern: "fastq", mode: "copy"
	publishDir "${params.out_dir}/guppy_output/", pattern: "sequencing_logs/sequencing_*.*", mode: "copy"

	label 'gpu'

	input:
	file("*")


	output:
	path "fastq/pass/barcode*", emit: fastq_ch
	path "fastq"
	file("logs/guppy_basecaller_*.log")
	path "sequencing_logs/sequencing_summary.txt", emit: summary_ch

	script:
	"""

  guppy_basecaller -x "cuda:all" \
        -c /cluster/projects/nn9305k/src/miniconda/envs/guppy_gpu_v6.5.7/data/$params.guppy.model \
        --barcode_kits $params.guppy.barcode \
		--detect_barcodes \
		--detect_mid_strand_barcodes \
		--enable_trim_barcodes \
		--num_barcoding_threads 12 \
		--num_barcoding_buffers 12 \
		--gpu_runners_per_device 24 \
        --num_callers 24 \
        --records_per_fastq 0 \
        --compress_fastq \
        --disable_pings \
        --min_qscore 7 \
        -i pod5 \
        -s fastq

	# moving log files
	mkdir logs
	mv fastq/guppy_basecaller_*.log logs/

	# moving sequencing telemetry and summary files
	mkdir sequencing_logs
	mv fastq/sequencing_*.* sequencing_logs/

	"""
}