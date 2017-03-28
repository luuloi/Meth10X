#!/bin/bash -e
# usage: bash biscuit.sh input output reference

# load module
export MODULEPATH=/share/ClusterShare/Modules/modulefiles/noarch:/share/ClusterShare/Modules/modulefiles/centos6.2_x86_64:/share/ClusterShare/Modules/modulefiles/contrib:$MODULEPATH
source /etc/profile.d/modules.sh
module load phuluu/biscuit/0.2.0
module load phuluu/pigz/2.3.4

# get paramaters
# $1=aligned/PrEC/PrEC.bam
input=$1
sample=$(basename $input| cut -d. -f1)
# $2=aligned/PrEC
output=$2
ref=$3
min_cov=$4


LOGFILE="${output}/${sample}.biscuit.vcf2bed.CpG.log"
echo `date`" *** Biscuit vcf2bed: SNP calling" > $LOGFILE
# CpG
# chr1	61946	61948	1.000	1	CG	CG
# chr1	61953	61955	1.000	1	CG	CG
# chr1	62081	62083	0.000	4	CG	CG
# chr1	62095	62097	0.000	4	CG	CG
echo "- Convert vcf to bed: CpG" >> $LOGFILE 
echo """ biscuit vcf2bed -k $min_cov -c -t cg "${output}/${sample}.BC.vcf.gz"|awk '{printf \"%s\\t%s\\t%s\\t%4.0f\\t%4.0f\n\", \$1, \$2, \$2, \$4*\$5, \$5}' > "${output}/${sample}.BC.CpG.bed" """ >> $LOGFILE
biscuit vcf2bed -k $min_cov -c -t cg "${output}/${sample}.BC.vcf.gz"|awk '{printf "%s\t%s\t%s\t%4.0f\t%4.0f\n", $1, $2, $2, $4*$5, $5}' > "${output}/${sample}.BC.CpG.bed" 2>> $LOGFILE

cmd="""pigz ${output}/${sample}.BC.CpG.bed """
echo $cmd >> "$LOGFILE"; eval $cmd 2>> "$LOGFILE"

echo `date`" Finished convert vcf to bed: CpG" >> $LOGFILE
