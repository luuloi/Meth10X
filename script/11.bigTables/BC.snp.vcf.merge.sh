#!bin/bash -e
# usage: bash methyldackel.sh input output reference

# module
module load gi/tabix/0.2.6
module load phuluu/perl/5.24.1
export PERL5LIB=/share/ClusterShare/software/contrib/phuluu/vcftools/src/perl/:$PERL5LIB
module load phuluu/vcftools/0.1.15

# get paramaters
# $1=/home/phuluu/data/WGBS10X_new/Test_Prostate/bigTable/MD_CpG.merge
input=$1
# $2=bigTables
output=$2

LOGFILE="$output/BC.snp.vcf.merge.log"
# /share/ClusterShare/software/contrib/phuluu/vcftools/bin/vcf-merge \
# /home/phuluu/data/WGBS10X_new/Test_Prostate/called/PrEC/PrEC.BC.snp.vcf.gz \
# /home/phuluu/data/WGBS10X_new/Test_Prostate/called/LNCaP/LNCaP.BC.snp.vcf.gz \
# > /home/phuluu/data/WGBS10X_new/Test_Prostate/bigTables/bigTable.BC.snp.vcf
echo `date`" *** Merge BC.snp.vcf.merge samples into bigTable" > $LOGFILE

echo "Sort and eliminate sample duplication" >> $LOGFILE
cmd="input_unique=\$(echo $input| awk '{for(i=1;i<=NF;i++){if(\$i ~ /BC.snp.vcf.merge/) print \$i}}'| sort -u)"
echo $cmd >> "$LOGFILE"; eval $cmd 2>> "$LOGFILE"; echo -e `date`" Finished sort\n" >> $LOGFILE

echo "Merge now ..." >> $LOGFILE
cmd="vcf-merge "
for i in `cat -s $input_unique`; do
cmd="${cmd} $i"; 
done
cmd="$cmd > $output/bigTable.snp.vcf"
echo $cmd >> "$LOGFILE"; eval $cmd 2>> "$LOGFILE"; echo -e `date`" Finished merge\n" >> $LOGFILE

cmd="gzip -f $output/bigTable.snp.vcf"
echo $cmd >> "$LOGFILE"; eval $cmd 2>> "$LOGFILE"; echo -e `date`" Finished zip\n" >> $LOGFILE

# cmd="tabix -f -p vcf $output/bigTable.snp.vcf.gz"
# echo $cmd >> "$LOGFILE"; eval $cmd 2>> "$LOGFILE"; echo -e `date`" Finished tabix\n" >> $LOGFILE

echo `date`" Finished merge BC.snp.vcf.merge samples into bigTable" >> $LOGFILE

# zcat called/PrEC//PrEC.MD.strands_CHC.tsv.gz| head
# #chr		position	strand	PrEC.C	PrEC.cov
# lambda	10473	-	0	0
# lambda	10480	+	0	0

