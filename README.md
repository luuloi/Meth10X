# WGBSX10

* WGBSX10 is a pipeline of parallel alignment whole genome bisulfite sequencing (WGBS) or nucleosome occupancy and DNA methylation (NOMEseq) from fastq files of multi samples (approx. 8-16 samples with more than 20X coverage for each) and generating:
  * A tsv big table of CG/CHH/CHG with filter/not filter SNP
  * SNP calling
  * bigwig of whole genome coverage, only CpG coverage, CpG methylation
  * An HTML report of quality control metrics 
of these samples

* WGBSX10 is built based on bash/python/R script, Bpipe and a collection of software packages:
  * [bwa-meth] (http://effectif.com/nesta) "bwa-meth"
  * bedtools
  * MethylDackel
  * Biscuit
  * MethylSeekR
  * trimCEGX
  * makeFullDataFrame
