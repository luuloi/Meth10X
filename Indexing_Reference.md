*** Indexing Reference Genome
** This is an example show how to make an indexing of reference genome, partically hg38.

** One need to install BSgenome.Hsapiens.UCSC.hg38 in R
module load R/3.4.0
R
source("https://bioconductor.org/biocLite.R")
biocLite("BSgenome.Hsapiens.UCSC.hg38")


** Find a place in cluster which free space is 90G and fast access from computer nodes
** make a folder name hg38

** Download lambda genome for spikein from

wget ftp://ftp.ncbi.nlm.nih.gov/genomes/Viruses/Enterobacteria_phage_lambda_uid14204/NC_001416.fna

+ change file name to hg38/lambda.fa
+ open lambda/lambda.fa and change the header from ">gi|9626243|ref|NC_001416.1| Enterobacteria phage lambda, complete genome" to ">lambda"

** run the script prepare_genome_hg38.sh

#!/bin/bash -e

# submit the jobs
module load R/3.4.0

ref="hg38"
o='/short/yo4/lpl913/annotations/WGBS10X'
cd $o

# 1.CHH_sites 
qsub -P un9 -q normalbw -l ncpus=24 -l mem=192G -l walltime=24:00:00 -V -l wd -N CHH_sites -o $o/$ref -e $o/$ref -- R -f /home/913/lpl913/allpipe/WGBSX10/indexing/new/CHH_sites.r --args $ref $o

# 2.CHG_sites 
qsub -P un9 -q normalbw -l ncpus=24 -l mem=192G -l walltime=24:00:00 -V -l wd -N CHG_sites -o $o/$ref -e $o/$ref -- R -f /home/913/lpl913/allpipe/WGBSX10/indexing/new/CHG_sites.r --args $ref $o

# 3.CpG_sites 
qsub -P un9 -q normalbw -l ncpus=16 -l mem=128G -l walltime=24:00:00 -V -l wd -N CpG_sites -o $o/$ref -e $o/$ref -- R -f /home/913/lpl913/allpipe/WGBSX10/indexing/new/CpG_sites.r --args $ref $o

# 4.CpG_island_shore: the working node have to have the internet connection 
qsub -P un9 -q copyq -l ncpus=1 -l mem=12G -l walltime=10:00:00 -V -l wd -N CpG_island_shore -o $o/$ref -e $o/$ref -- R -f /home/913/lpl913/allpipe/WGBSX10/indexing/new/CpG_island_shore.r --args $ref $o

# 5.export.DNAseq.in.fasta.r and run bwm-meth index
qsub -P un9 -q normalbw -l ncpus=16 -l mem=128G -l walltime=24:00:00 -V -l wd -N CpG_island_shore -o $o/$ref -e $o/$ref -- bash /home/913/lpl913/allpipe/WGBSX10/indexing/new/indexing.sh $ref $o

# 6.CGH_sites_NOMEseq
qsub -P un9 -q normalbw -l ncpus=24 -l mem=192G -l walltime=24:00:00 -V -l wd -N CHH_sites -o $o/$ref -e $o/$ref -- R -f /home/913/lpl913/allpipe/WGBSX10/indexing/new/CGH_sites_NOMEseq.r --args $ref $o

# 7.HCH_sites_NOMEseq 
qsub -P un9 -q normalbw -l ncpus=24 -l mem=192G -l walltime=24:00:00 -V -l wd -N CHG_sites -o $o/$ref -e $o/$ref -- R -f /home/913/lpl913/allpipe/WGBSX10/indexing/new/HCH_sites_NOMEseq.r --args $ref $o

# 8.WCG_sites_NOMEseq 
qsub -P un9 -q normalbw -l ncpus=24 -l mem=192G -l walltime=24:00:00 -V -l wd -N CpG_sites -o $o/$ref -e $o/$ref -- R -f /home/913/lpl913/allpipe/WGBSX10/indexing/new/WCG_sites_NOMEseq.r --args $ref $o





