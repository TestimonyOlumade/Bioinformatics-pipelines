#!/bin/bash

# This RNA Seq pipeline will run all the way from having the raw sequencing output files (fastq/fastq.gz) and running 
# fastqc on them to having feature counts (quantification)

# Dependencies include
# - Fastqc (v 0.11.9)
# - Trimmomatic (v 0.39)
# - HISAT2 (v 2.2.1)
# - featureCounts (v 2.0.3)
# - fastq/fastqc files in a folder of interest, and in a working directory of interest
# - the genome indices of interest. Check url to the gi and append to the code
# - gene annotation file. Check url and append to the code

# Study links

# installing bioinformatics softwares: https://xie186.github.io/Novice2Expert4Bioinformatics/install-bioinformatics-software-in-linux.html
------
 
SECONDS=0

# simply to return the amount it takes to run the whole pipeline at the end of the analysis

Cd ~/users/RNASeq_pipeline/

# change working directory to wherever you want to carryout the analysis


# STEP 1: Run Fastqc on the raw sequencing output files (fastq.gz)

mkdir Fastqc 

Fastqc data/Sample1.fastq -o ./fastqc/

# you will need the command (fastqc), 
# the path to the raw sequencing output files (data/Sample1.fastq) - assuming you also have a folder called 'data' and it contains all of the fastq files from the sequencer
# any options of choice for the fastq command (check the manual 'fastqc -h' for more info)
# '-o' means you are trying to specify the output
# the output folder

echo "fastq completed"


# STEP 2: Trim reads with poor quality and remove adapter sequences

#After fastq is completed, take a look at the output files, especially the fastq.html file, and visually inspect the quality control report. 
# if there is need for trimming, then run Trimmomatic.
# otherwise, skip to step 3

mkdir Trimming

java -jar tools/Trimmomatic-0.39/trimmomatic-0.39.jar SE -threads 4 data/Sample1.fastq Trimming/Sample1_trimmed.fastq TRAILING:10 -phred33

# SE - single-ended reads
# TRAILING:10 - Trim 10 bases towards the end of the reads
# Phred33 - convert quality scores to phred quality score format.

# trimming is only done when necessary, and the command line above should only be run when there is a need to, otherwise, it can be 'commented out' of the whole code by adding the '#' sign to the front of the command line.

echo "Trimming completed!"

mkdir Trimmed_fastqc

fastqc Trimming/Sample1_trimmed.fastq -o Trimming/Trimmed_fastqc/

# this is just to verify that trimming was done on the poor quality reads by viewing the qc html report again


# STEP 3: Run HISAT2 

# this will carryout alignment to the reference genome using the .fastq/fastq.gz files in the data folder (if trimming was not done),
# or the '*_trimmed.fastq' file in the Trimming folder (if trimming was done)

mkdir HISAT2

cd HISAT2

wget https://genome-idx.s3.amazonaws.com/hisat/grch38_genome.tar.gz

# link to download the genome indices of choice from HISAT2 website
# the above example is for the human genome indices

hisat2 -q --rna-strandedness R -x HISAT2/grch38/genome -U Trimming/Sample1_trimmed.fastq | 
samtools sort -o HISAT2/Sample1_trimmed.bam

# strandedness-specific info (whether forward F or reverse R)  in mapping is important because it improves the resolution of multimapped reads and anti-sense overlapped genes
# U - unpaired - for single-ended reads
# samtools will help convert and manipulate bam files

echo "HISAT2 completed!"


# STEP 4: Run Feature Counts / Quantification

mkdir ../Featurecounts

cd ../Featurecounts

mkdir quants

# download the relevant gene annotation file (.gtf) from Ensembl 

wget http://ftp.ensembl.org/pub/release-106/gtf/homo_sapiens/Homo_sapiens.GRCh38.106.gtf.gz 

# using the human genome annotation file as an example

featureCounts -S 2 -a ./hg38/Homo_sapiens.GRCh38.106.gtf -o ./quants/Sample1_featurecounts.txt ../HISAT2/Sample1_trimmed.bam

# -S - strandedness - 1: Forward, 2: Reverse
# -o - output file path

echo "featureCounts completed!"

duration = $SECONDS

echo "$(($duration / 60)) minutes and $(($duration % 60)) seconds elapsed."

#returns the time taken to complete the analysis.




















