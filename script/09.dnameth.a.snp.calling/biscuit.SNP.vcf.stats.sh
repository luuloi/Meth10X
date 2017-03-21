#!/bin/bash -e
# usage: bash biscuit.sh input output reference
# set -x
# load module
export MODULEPATH=/share/ClusterShare/Modules/modulefiles/noarch:/share/ClusterShare/Modules/modulefiles/centos6.2_x86_64:/share/ClusterShare/Modules/modulefiles/contrib:$MODULEPATH
source /etc/profile.d/modules.sh
module load phuluu/perl/5.24.1
export PERL5LIB=/share/ClusterShare/software/contrib/phuluu/vcftools/src/perl/:$PERL5LIB
module load phuluu/vcftools/0.1.15

# get paramaters
# $1=aligned/PrEC/PrEC.bam
input=$1
sample=$(basename $input| cut -d. -f1)
# $2=aligned/PrEC
output=$2
ref=$3


LOGFILE="${output}/${sample}.biscuit.SNP.vcf.stats.log"
echo `date`" *** Biscuit SNP calling: Make statistics of SNP" > $LOGFILE

cmd="""vcf-stats ${output}/${sample}.BC.snp.vcf.gz > ${output}/${sample}.BC.snp.vcf.gz.stats"""
echo $cmd >> "$LOGFILE"; eval $cmd 2>> "$LOGFILE"

echo "Convert Vcf-stats output to table format" >> $LOGFILE
sed ':a;N;$!ba;s/\n//g' "${output}/${sample}.BC.snp.vcf.gz.stats"| tr -d " "| egrep -oh "'snp'=>{.*},"| cut -d} -f1| cut -d{ -f2| tr "," "\n"| sed 's/=>/\t/'| sort -nrk 2,2 > "${output}/${sample}.BC.snp.vcf.gz.stats.tsv" 2>> $LOGFILE
echo -e `date`" Finished - Convert bed to vcf: SNP\n" >> $LOGFILE
