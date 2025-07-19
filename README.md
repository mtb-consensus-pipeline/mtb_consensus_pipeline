# M. tuberculosis consensus pipeline

This Nextflow pipeline maps paired-end FASTQ reads to the M. tuberculosis H37Rv v3 reference,
calls variants and produces a consensus FASTA.

## Requirements

- Nextflow ≥ 20.x  
- minimap2  
- samtools (bcftools)  
- tabix  

## Usage

```bash
nextflow run main.nf \
  --reads_dir data/fastq \
  --reference data/reference/H37Rv_v3.fasta \
  --out_prefix my_sample
cd ~/mtb_consensus_pipeline


Note: This pipeline has been developed against Nextflow 25.04.6 and tested with minimap2 v2.30, samtools/bcftools v1.22.
