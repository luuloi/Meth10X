*** Indexing Reference Genome
** This is an example show how to make an indexing of reference genome, partically hg38.

** One need to install BSgenome.Hsapiens.UCSC.hg38 in R
module load R/3.4.0
R
source("https://bioconductor.org/biocLite.R")
biocLite("BSgenome.Hsapiens.UCSC.hg38")

** Download lambda genome for spikein from

ftp://ftp.ncbi.nlm.nih.gov/genomes/Viruses/Enterobacteria_phage_lambda_uid14204/NC_001416.fna

change the header from ">gi|9626243|ref|NC_001416.1| Enterobacteria phage lambda, complete genome" to "lambda"


