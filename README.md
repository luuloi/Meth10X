# WGBSX10

* WGBSX10 is a pipeline of parallel alignment whole genome bisulfite sequencing (WGBS) or nucleosome occupancy and DNA methylation (NOMEseq) from fastq files of multi samples (approx. 8-16 samples with more than 20X coverage for each) and generating:
  * A tsv big table of CG/CHH/CHG with filter/not filter SNP
  * SNP calling
  * PMD, LMR, UMR, HMR calling 
  * bigwig files of whole genome coverage, only CpG coverage, CpG methylation of each sample for IGV visualization
  * An HTML report of quality control detail metrics 
of these samples

* WGBSX10 helps to fasten the whole workflow of WGBS as well as enhance the accurate of methylation and SNP calling.

* WGBSX10 is built based on in-house bash/python/perl/R script, Bpipe and a collection of software packages:
  * [bwa]          https://github.com/lh3/bwa
  * [bwa-meth]     https://github.com/brentp/bwa-meth
  * [samtools]     https://github.com/samtools/
  * [tabix]        https://github.com/samtools/tabix
  * [qualimap]     http://qualimap.bioinfo.cipf.es/
  * [SAMStat]      http://samstat.sourceforge.net/
  * [picardtools]  https://github.com/broadinstitute/picard
  * [bedtools]     https://github.com/arq5x/bedtools2
  * [bamUtil]      https://github.com/statgen/bamUtil
  * [MethylDackel] https://github.com/dpryan79/MethylDackel
  * [Biscuit]      https://github.com/zwdzwd/biscuit
  * [MethylSeekR]  https://github.com/Bioconductor-mirror/MethylSeekR
  * [Vcf-tools]    https://github.com/vcftools
  * [fastqc]       http://www.bioinformatics.babraham.ac.uk/projects/fastqc/
  * [trimCEGX]     https://github.com/luuloi/trim.paired.read
  * [makeFullDataFrame] https://github.com/luuloi/make.full.data.frame
  * [merge_columns_multi_tsv] https://github.com/luuloi/merge_columns_multi_tsv
  * [UCSC-format-file-converter]  http://hgdownload.soe.ucsc.edu/admin/exe/linux.x86_64/
  * [ggplot2]      https://github.com/tidyverse/ggplot2

* Dependencies: [TODO]
  * Java version >= 1.8

* Installation: [TODO]

* Fist Run: [TODO]

* Second Run: [TODO]

* Inputs require: fastq files in .gz format
* Outputs [TODO]
  * Big table of 2 samples
  * HTML report
