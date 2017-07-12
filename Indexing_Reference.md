*** Indexing Reference Genome
** This is an example show how to make an indexing of reference genome, partically hg38.

** One need to install BSgenome.Hsapiens.UCSC.hg38 in R
module load R/3.4.0
R
source("https://bioconductor.org/biocLite.R")
biocLite("BSgenome.Hsapiens.UCSC.hg38")

** Download lambda genome for spikein from

wget ftp://ftp.ncbi.nlm.nih.gov/genomes/Viruses/Enterobacteria_phage_lambda_uid14204/NC_001416.fna

+ change file name to lambda/lambda.fa
+ open lambda/lambda.fa and change the header from ">gi|9626243|ref|NC_001416.1| Enterobacteria phage lambda, complete genome" to ">lambda"

** run the script prepare_genome_hg38.sh

#!/bin/bash -e

o='/home/phuluu/methods/darlo/annotations/'
e='/home/phuluu/methods/darlo/annotations/'

qsub -j y -pe smp 20 -l mem_requested=8GB -wd `pwd` -b y -o $o -e $e bash /home/phuluu/methods/darlo/annotations/prepare_genomes_hg38.sh




