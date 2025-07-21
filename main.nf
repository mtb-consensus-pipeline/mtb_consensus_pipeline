#!/usr/bin/env nextflow

/*
 * TB consensus pipeline
 * Maps paired-end FASTQ reads to M. tuberculosis H37Rv v3,
 * calls variants and produces a consensus FASTA.
 */

 // Reference: H37Rv v3 (NCBI accession 448814763)

params.reads_dir  = params.reads_dir ?: error("Please set --reads_dir")
params.reference  = file(params.reference) ?: error("Please set --reference")
params.out_prefix = params.out_prefix ?: error("Please set --out_prefix")


Channel
    .fromFilePairs("${params.reads_dir}/*_{1,2}.fastq.gz", flat: true)
    .set { read_pairs }

// Check that there is only one sample in the input directory
read_pairs
    .ifEmpty { error "No FASTQ pairs found in input directory." }
    .view { pairs -> 
        if (pairs.size() > 1) {
            error "More than one sample detected in the input directory. Please provide only one sample."
        }
    }

/////////////////////////////////////////
// Align reads and sort BAM
/////////////////////////////////////////
process ALIGN {
    // Align paired-end reads to the reference genome and sort/index the BAM file
    tag "$sample_id"

    input:
      tuple val(sample_id), path(read1), path(read2)

    output:
      tuple val(sample_id), path("${sample_id}.bam")

    script:
    """
    minimap2 -ax sr ${params.reference} ${read1} ${read2} \
      | samtools view -b - \
      | samtools sort -o ${sample_id}.bam

    samtools index ${sample_id}.bam
    """
}

/////////////////////////////////////////
// Call variants: produce bgzipped VCF + .tbi index
/////////////////////////////////////////
process CALL_VARIANTS {
    // Call variants using bcftools, output compressed VCF and index
    tag "$sample_id"

    input:
      tuple val(sample_id), path(bam)

    output:
      tuple val(sample_id), path("${sample_id}.vcf.gz"), path("${sample_id}.vcf.gz.tbi")

    script:
    """
    # generate bgzipped VCF and index it
    bcftools mpileup -f ${params.reference} ${bam} -Ou \\
      | bcftools call -mv -Oz -o ${sample_id}.vcf.gz
    tabix -p vcf ${sample_id}.vcf.gz
    """
}

/////////////////////////////////////////
// Generate consensus
/////////////////////////////////////////
process CONSENSUS {
    // Generate consensus FASTA from reference and VCF
    tag "$sample_id"

    input:
      tuple val(sample_id), path(vcf), path(vcf_tbi)

    output:
      path("${params.out_prefix}.fasta")

    script:
    """
    bcftools consensus -f ${params.reference} ${vcf} \
      > ${params.out_prefix}.fasta
    """
}

/////////////////////////////////////////
// Workflow definition
/////////////////////////////////////////
workflow {
    read_pairs
      | ALIGN
      | CALL_VARIANTS
      | CONSENSUS
}

/////////////////////////////////////////
// END
/////////////////////////////////////////
_Submitted by Basma Baqqali_
