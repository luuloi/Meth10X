#!/bin/bash -e
# usage: bash biscuit.sh input output reference

# load module
export MODULEPATH=/share/ClusterShare/Modules/modulefiles/noarch:/share/ClusterShare/Modules/modulefiles/centos6.2_x86_64:/share/ClusterShare/Modules/modulefiles/contrib:$MODULEPATH
source /etc/profile.d/modules.sh
module load phuluu/biscuit/0.2.0

# get paramaters
# $1=aligned/PrEC/PrEC.bam
input=$1
sample=$(basename $input| cut -d. -f1)
# $2=aligned/PrEC
output=$2
ref=$3
min_cov=$4

LOGFILE="${output}/${sample}.biscuit.vcf2bed.SNP.log"
echo `date`" *** Biscuit vcf2bed: SNP calling" > $LOGFILE

# SNP
# #CHROM	POS	ID	REF	ALT	QUAL	FILTER	INFO	FORMAT	LNCaP
# chr1	772755	.	A	C	26	PASS	NS=1	DP:GT:GP:GQ:SP	1:1/1:6,8,0:26:C1

echo "- SNP calling" >> $LOGFILE
echo """ biscuit vcf2bed -k $min_cov -c -t snp "${output}/${sample}.BC.vcf.gz" > "${output}/${sample}.BC.snp.bed" """ >> $LOGFILE
biscuit vcf2bed -k $min_cov -c -t snp "${output}/${sample}.BC.vcf.gz" > "${output}/${sample}.BC.snp.bed" 2>> $LOGFILE
echo `date`" Finished convert vcf to bed: SNP calling" >> $LOGFILE
