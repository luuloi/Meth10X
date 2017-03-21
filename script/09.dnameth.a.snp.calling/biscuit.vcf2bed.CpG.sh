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


LOGFILE="${output}/${sample}.biscuit.vcf2bed.CpG.log"
echo `date`" *** Biscuit vcf2bed: SNP calling" > $LOGFILE
# CpG
# chr1	61946	61948	1.000	1	CG	CG
# chr1	61953	61955	1.000	1	CG	CG
# chr1	62081	62083	0.000	4	CG	CG
# chr1	62095	62097	0.000	4	CG	CG
echo "- Convert vcf to bed: CpG" >> $LOGFILE 
echo """ $biscuit vcf2bed -k 1 -c -t cg "${output}/${sample}.BC.vcf.gz"|awk '{printf \"%s\\t%s\\t%s\\t%4.0f\\t%4.0f\n\", \$1, \$2, \$2, \$4*\$5, \$5}' > "${output}/${sample}.BC.CpG.bed" """ >> $LOGFILE
$biscuit vcf2bed -k 1 -c -t cg "${output}/${sample}.BC.vcf.gz"|awk '{printf "%s\t%s\t%s\t%4.0f\t%4.0f\n", $1, $2, $2, $4*$5, $5}' > "${output}/${sample}.BC.CpG.bed" 2>> $LOGFILE

cmd="""gzip ${output}/${sample}.BC.CpG.bed """
echo $cmd >> "$LOGFILE"; eval $cmd 2>> "$LOGFILE"

echo `date`" Finished convert vcf to bed: CpG" >> $LOGFILE
