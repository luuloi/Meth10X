#!/bin/bash -e
# usage: bash biscuit.sh input output reference

# load module
export MODULEPATH=/share/ClusterShare/Modules/modulefiles/noarch:/share/ClusterShare/Modules/modulefiles/centos6.2_x86_64:/share/ClusterShare/Modules/modulefiles/contrib:$MODULEPATH 
export PATH=/home/phuluu/bin:$PATH
source /etc/profile.d/modules.sh
module load gi/tabix/0.2.6


# get paramaters
# $1=aligned/PrEC/PrEC.bam
input=$1
sample=$(basename $input| cut -d. -f1)
# $2=aligned/PrEC
output=$2
ref=$3


LOGFILE="${output}/${sample}.biscuit.convert.SNP.bed.to.vcf.log"
echo `date`" *** Biscuit SNP calling" > $LOGFILE

# SNP
# #CHROM	POS	ID	REF	ALT	QUAL	FILTER	INFO	FORMAT	LNCaP
# chr1	772755	.	A	C	26	PASS	NS=1	DP:GT:GP:GQ:SP	1:1/1:6,8,0:26:C1

echo "- Convert SNP bed to vcf" >> $LOGFILE
# tabix -h /home/phuluu/data/WGBS10X_new/Test_Prostate/called/LNCaP/LNCaP.BC.vcf.gz -B /home/phuluu/data/WGBS10X_new/Test_Prostate/called/LNCaP/LNCaP.BC.snp.bed| grep -v lambda
cmd="""
tabix -h  ${output}/${sample}.BC.vcf.gz -B ${output}/${sample}.BC.snp.bed| grep -v lambda > ${output}/${sample}.BC.snp.vcf
"""
echo $cmd >> "$LOGFILE"; eval $cmd 2>> "$LOGFILE"
echo `date`" Finished convert bed to vcf: SNP calling" >> $LOGFILE

echo $cmd >> "$LOGFILE"; eval $cmd 2>> "$LOGFILE"
cmd="""bgzip ${output}/${sample}.BC.snp.vcf"""
echo $cmd >> "$LOGFILE"; eval $cmd 2>> "$LOGFILE"

cmd="""tabix -f -p vcf ${output}/${sample}.BC.snp.vcf.gz"""
echo $cmd >> "$LOGFILE"; eval $cmd 2>> "$LOGFILE"

cmd="""rm ${output}/${sample}.BC.snp.bed"""
echo $cmd >> "$LOGFILE"; eval $cmd 2>> "$LOGFILE"

echo `date`" Finished zip" >> $LOGFILE
