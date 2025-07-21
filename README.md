# M. tuberculosis Consensus Pipeline

_Submitted by Basma Baqqali_

This Nextflow pipeline maps paired-end FASTQ reads to the M. tuberculosis H37Rv v3 reference,
calls variants and produces a consensus FASTA.

## Requirements

- Nextflow ≥ 20.x  
- minimap2  
- samtools (bcftools)  
- tabix  

## Input file structure

Your input files should be organised as follows:

data/
fastq/
sample_1.fastq.gz
sample_2.fastq.gz
reference/
H37Rv_v3.fasta

- `sample_1.fastq.gz`: Forward reads  
- `sample_2.fastq.gz`: Reverse reads  
- `H37Rv_v3.fasta`: Reference genome (version 3, NCBI accession 448814763)  

## Downloading the reference genome

You can download the H37Rv version 3 reference genome (NCBI accession 448814763) as follows:

## Downloading the reference genome

You can obtain the H37Rv version 3 reference genome (NCBI accession NC_000962.3) in FASTA format as follows:

- **Manually:**  
  Go to [https://www.ncbi.nlm.nih.gov/nuccore/NC_000962.3?report=fasta](https://www.ncbi.nlm.nih.gov/nuccore/NC_000962.3?report=fasta),  
  then click "Send to" > "File" > "Create file" to download the FASTA.

- **(Optional) Using Entrez Direct:**  
  If you have [Entrez Direct](https://www.ncbi.nlm.nih.gov/books/NBK179288/) installed, you can use:
  ```bash
  efetch -db nucleotide -id NC_000962.3 -format fasta > H37Rv_v3.fasta
  ```

## Pipeline steps

The pipeline consists of the following steps:

1. Alignment: Paired-end FASTQ reads are aligned to the reference genome using minimap2.
2. Sorting and indexing: The alignments are sorted and indexed using samtools.
3. Variant calling: Variants are called with bcftools mpileup and call, producing a VCF file.
4. Consensus generation: A consensus FASTA file is generated from the VCF and reference using bcftools consensus.

## Usage

```bash
nextflow run main.nf \
  --reads_dir data/fastq \
  --reference data/reference/H37Rv_v3.fasta \
  --out_prefix my_sample
cd ~/mtb_consensus_pipeline

Note: This pipeline has been developed against Nextflow 25.04.6 and tested with minimap2 v2.30, samtools/bcftools v1.22.
```

## Note on input

This pipeline is designed to process a single sample at a time.  
Please ensure that only one pair of FASTQ files (forward and reverse) is present in the input directory.  
If multiple samples are present, only the first will be processed and the output may be overwritten.
