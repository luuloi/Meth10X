#!/bin/bash -e
# install 
. /etc/profile.d/modules.sh
export MODULEPATH=/share/ClusterShare/Modules/modulefiles/noarch:/share/ClusterShare/Modules/modulefiles/centos6.2_x86_64:/share/ClusterShare/Modules/modulefiles/contrib:/usr/share/Modules/modulefiles:/etc/modulefiles

# module load gi/gcc/4.8.2
# module load gi/samtools/1.1
module load aarsta/R/3.1.1
# R="/home/phuluu/src/R-devel/builddir/bin/R"
# module load aarsta/bwa/0.7.9a
# module load aarsta/bwa-meth/git
# module load fabbus/python/2.7.3
# module load gi/picard-tools/1.121

# # hg38
# mkdir -p hg38
# cd hg38

# # Get transcript gtf from ensembl and gunzip
# # wget ftp://ftp.ensembl.org/pub/release-75/gtf/homo_sapiens/Homo_sapiens.GRCh37.75.gtf.gz
# wget ftp://ftp.ensembl.org/pub/release-87/gtf/homo_sapiens/Homo_sapiens.GRCh38.87.gtf.gz
# gunzip Homo_sapiens.GRCh38.87.gtf.gz

# Create reference fasta file, granges objects of methylation sites for WGBS/NOMe and CpGislands
`which R` -f "/home/phuluu/Projects/WGBS10X_new/V02/script/genome.hg19/make_genome_tsv.R" --args hg19 Homo_sapiens.GRCh38.87.gtf /home/phuluu/data/annotations/hg19/ source

# # Add lambda to the fasta and index
# cat ../lambda/lambda.fa >> hg38.fa
# samtools faidx hg38.fa
# $PICARD_HOME/CreateSequenceDictionary.jar R=hg38.fa O=hg38.dict
# bwameth.py index hg38.fa
# cd ..

