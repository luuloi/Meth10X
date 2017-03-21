#!/bin/bash -e

# run this script
# bash ~/Projects/WGBS10X_new/V02/script/09.dnameth.a.snp.calling/MethylSeekR.sh aligned/PrEC/PrEC.bam called/PrEC /home/phuluu/Projects/WGBS10X_new/V02/annotations/hg19/hg19.fa

# load module 
export MODULEPATH=/share/ClusterShare/Modules/modulefiles/noarch:/share/ClusterShare/Modules/modulefiles/centos6.2_x86_64:/share/ClusterShare/Modules/modulefiles/contrib:$MODULEPATH 
export PATH=/home/phuluu/bin:$PATH
source /etc/profile.d/modules.sh
module load gi/bedtools/2.22.0

# get paramaters
# $1=aligned/PrEC/PrEC.bam
sample=$(basename $1| cut -d. -f1)
# $2=calls/PrEC
input_MD="$2/${sample}.MD_CpG.tsv"
input_BC="$2/${sample}.BC.snp.vcf.gz"
output="$2/${sample}.snp.filter.summary.txt"
# # example
# input="/home/phuluu/data/WGBS10X_new/Test_Prostate/merged/PrEC/PrEC.bam"
# sample="PrEC"
# output="/home/phuluu/data/WGBS10X_new/Test_Prostate/called/PrEC"
LOGFILE="$2/${sample}.filter.snp.log"

echo `date`" *** Filter SNP " > $LOGFILE

echo " - Get only CpGs having coverage > 0" >> $LOGFILE
cmd="""
awk '{OFS=\"\t\"}NR>1{if(\$4>0) print \$1,\$2-1,\$2+1,\$3,\$4}' $input_MD > ${input_MD}.bed
"""
echo $cmd >> $LOGFILE; eval $cmd 2>> $LOGFILE;

echo " - Count number of row of CpG > 0 coverage table" >> $LOGFILE
cmd="""
nrow_before=\$(wc -l ${input_MD}.bed| awk '{print \$1}')
"""
echo $cmd >> $LOGFILE; eval $cmd 2>> $LOGFILE;

echo " - Intersect CpG > 0 coverage table with SNP table and filter out these SNPs" >> $LOGFILE
cmd="""
bedtools intersect -a ${input_MD}.bed -b <(zcat $input_BC) -v| awk '{print \$1,\$2+1,\$4,\$5}' > ${input_MD}.filter.out.snp.tsv
"""
echo $cmd >> $LOGFILE; eval $cmd 2>> $LOGFILE

echo " - Count number of row of CpG > 0 coverage after filtered table" >> $LOGFILE
cmd="""
nrow_after=\$(wc -l ${input_MD}.filter.out.snp.tsv| awk '{print \$1}')
"""
echo $cmd >> $LOGFILE; eval $cmd 2>> $LOGFILE;

echo " - Calculate number of CpGs overlaped with SNPs" >> $LOGFILE
cmd="""
overlap=\$(bc <<< \"$nrow_before - $nrow_after\");
percent=\$(bc <<< \"scale=2; 100*\$overlap/\$nrow_before\");
"""
echo $cmd >> $LOGFILE; eval $cmd 2>> $LOGFILE

echo "Number of CpGs with at least 1 coverage = $nrow_before" > $output;
echo "Number of CpGs and SNPs overlaping = $overlap" >> $output;
echo "Percent overlaping = ${percent}%" >> $output;

echo "*** Zip the output file"  >> $LOGFILE
cmd="""
rm ${input_MD}.bed;
gzip ${input_MD}.filter.out.snp.tsv;
"""
echo $cmd >> $LOGFILE; eval $cmd 2>> $LOGFILE

echo -e `date`" Finished - Filter out SNPs" >> $LOGFILE
