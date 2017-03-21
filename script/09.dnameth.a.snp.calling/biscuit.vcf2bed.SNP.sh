#!/bin/bash -e
# usage: bash biscuit.sh input output reference

# load module
export MODULEPATH=/share/ClusterShare/Modules/modulefiles/noarch:/share/ClusterShare/Modules/modulefiles/centos6.2_x86_64:/share/ClusterShare/Modules/modulefiles/contrib:$MODULEPATH 
export PATH=/home/phuluu/bin:$PATH
source /etc/profile.d/modules.sh
module load phuluu/perl/5.24.1
export PERL5LIB=/share/ClusterShare/software/contrib/phuluu/vcftools/src/perl/:$PERL5LIB
module load gi/bedtools/2.22.0
module load gi/tabix/0.2.6
biscuit="/home/phuluu/methods/DNAmeth.calling.method.comparison/biscuit/biscuit"
vcf_stats="/share/ClusterShare/software/contrib/phuluu/vcftools/bin/vcf-stats"

# get paramaters
# $1=aligned/PrEC/PrEC.bam
input=$1
sample=$(basename $input| cut -d. -f1)
# $2=aligned/PrEC
output=$2
ref=$3


LOGFILE="${output}/${sample}.biscuit.vcf2bed.SNP.log"
echo `date`" *** Biscuit vcf2bed: SNP calling" > $LOGFILE

# SNP
# #CHROM	POS	ID	REF	ALT	QUAL	FILTER	INFO	FORMAT	LNCaP
# chr1	772755	.	A	C	26	PASS	NS=1	DP:GT:GP:GQ:SP	1:1/1:6,8,0:26:C1

echo "- SNP calling" >> $LOGFILE
echo """ $biscuit vcf2bed -k 1 -c -t snp "${output}/${sample}.BC.vcf.gz" > "${output}/${sample}.BC.snp.bed" """ >> $LOGFILE
$biscuit vcf2bed -k 1 -c -t snp "${output}/${sample}.BC.vcf.gz" > "${output}/${sample}.BC.snp.bed" 2>> $LOGFILE
echo `date`" Finished convert vcf to bed: SNP calling" >> $LOGFILE
