#!/bin/bash -e
# usage: bash biscuit.sh input output reference

# load module
export MODULEPATH=/share/ClusterShare/Modules/modulefiles/noarch:/share/ClusterShare/Modules/modulefiles/centos6.2_x86_64:/share/ClusterShare/Modules/modulefiles/contrib:$MODULEPATH
source /etc/profile.d/modules.sh
module load phuluu/samtools/1.4
module load phuluu/biscuit/0.2.0


# get paramaters
# $1=aligned/PrEC/PrEC.bam
input=$1
sample=$(basename $input| cut -d. -f1)
# $2=aligned/PrEC
output=$2
ref=$3
min_cov=$4
ncores=14

mkdir -p $output

LOGFILE="${output}/${sample}.biscuit.pileup.log"
echo `date`" *** Biscuit pileup: SNP calling" > $LOGFILE

# 5 hours
echo "- Pileup" >> $LOGFILE
echo """ biscuit pileup -m 60 -b 20 -k $min_cov -t 100000 -r $ref -i $input -o "${output}/${sample}.BC.vcf" -q $ncores -P 0.001 -Q 0.900 """ >> $LOGFILE
biscuit pileup -m 60 -b 20 -k $min_cov -t 100000 -r $ref -i $input -o "${output}/${sample}.BC.vcf" -q $ncores -P 0.001 -Q 0.900 2>> $LOGFILE
echo `date`" - Finished Biscuit pileup" >> $LOGFILE

# bgzip vcf file
# module load gi/tabix/0.2.6
# bgzip /home/phuluu/data/WGBS10X_new/Test_Prostate/called/LNCaP/LNCaP.BC.vcf
# tabix -p vcf /home/phuluu/data/WGBS10X_new/Test_Prostate/called/LNCaP/LNCaP.BC.vcf.gz
cmd="bgzip -@ $ncores ${output}/${sample}.BC.vcf"
echo $cmd >> "$LOGFILE"; eval $cmd 2>> "$LOGFILE"

cmd="tabix -p vcf ${output}/${sample}.BC.vcf.gz"
echo $cmd >> "$LOGFILE"; eval $cmd 2>> "$LOGFILE"

echo `date`" - Finished processing $1" >> "$LOGFILE"
