process EMU_CLASS {
	/* this process takes the output of NanoFilt and runs it through the EMU classification tool
	* 
	*/
	//errorStrategy 'ignore'


	conda "/cluster/projects/nn9305k/src/miniconda/envs/emu_amplicon"

	publishDir "${params.out_dir}/emu_classification/", pattern: "*", mode: "copy"

	label 'heavy'

	input:
	file(x)

	output:
	tuple val(samplename), path {"*"}
	path {"*.tsv"}, emit: classify_ch

	script:
	samplename = x.toString() - ~/.nfilt.fastq.gz$/
	"""
	ls -la
  	emu abundance\
        --type map-ont \
        --min-abundance 0.0001 \
        --db $params.emu.db \
        --output-dir ./${samplename}.emu \
        --keep-counts \
        --output-unclassified \
        --threads 20 \
        *.fastq.gz

	ln -s ${samplename}.emu/${samplename}.nfilt.fastq_rel-abundance.tsv ./${samplename}.rel-abundance.tsv

	"""
}


process EMU_COMBINE {
	/* this process takes the output of EMU from different samples and then combines them in one file
	 * Note this function will select all the .tsv files in the provided directory that contain 'rel-abundance' in the filename.
	 * Combined table will only include all ranks above the specified rank according to this list: 
	 * [tax_id, species, genus, family, order, class, phylum, superkingdom]. Specified rank must be in this list and in each of the included Emu outputs.
	 * Combined table will be created in the provided directory path with the file name: emu-combined-<rank>.tsv. In order to include tax_id in your output, specific <rank> as "tax_id".
	 */

	//errorStrategy 'ignore'


	conda "/cluster/projects/nn9305k/src/miniconda/envs/emu_amplicon"

	publishDir "${params.out_dir}/emu_classification/", pattern: "*", mode: "copy"

	label 'medium'

	input:
	file(x)

	output:
	tuple val(samplename), path {"*"}

	script:
	samplename = x.toString() - ~/.nfilt.fastq.gz$/
	"""
	ls
  	for taxon in species genus family order class phylum superkingdom; do echo running \$taxon ; emu combine-outputs ./ \$taxon ; done

	"""
}