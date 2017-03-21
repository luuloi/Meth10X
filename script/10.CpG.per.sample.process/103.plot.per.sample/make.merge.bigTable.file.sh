#!bin/bash -e
# usage: bash methyldackel.sh input output reference

# load module 
export MODULEPATH=/share/ClusterShare/Modules/modulefiles/noarch:/share/ClusterShare/Modules/modulefiles/centos6.2_x86_64:/share/ClusterShare/Modules/modulefiles/contrib:$MODULEPATH 
export PATH=/home/phuluu/bin:$PATH
source /etc/profile.d/modules.sh

# get paramaters
# $1=called/PrEC/PrEC.MD_CpG.tsv.gz
input=$1
sample=$(basename ${input/.gz/})
# $2=bigTable/merge
output=$2
mkdir -p $output
LOGFILE="$output/${sample}.make.merge.bigTable.file.log"

echo `date`" - MD_CpG.merge" > $LOGFILE
# paste <(head /home/phuluu/Projects/WGBS10X_new/V02/annotations/hg19/hg19.CpG.bed| cut -f1,3,6) \
# <(zcat /home/phuluu/data/WGBS10X_new/Test_Prostate/called/PrEC/PrEC.MD_CpG.tsv.gz| cut -f5,6|head) \
# <(zcat /home/phuluu/data/WGBS10X_new/Test_Prostate/called/LNCaP/LNCaP.MD_CpG.tsv.gz| cut -f5,6| head)
cmd=""" echo $input > "$output/${sample}.MD_CpG.merge" """
echo $cmd >> "$LOGFILE"; eval $cmd 2>> "$LOGFILE"; echo `date`" - Finished MD_CpG.merge" >> $LOGFILE

echo `date`" - MD.strand_CpG.merge" >> $LOGFILE
# paste <(head /home/phuluu/Projects/WGBS10X_new/V02/annotations/hg19/hg19.CpG.strands.bed| cut -f1,3,6) \
# <(zcat /home/phuluu/data/WGBS10X_new/Test_Prostate/called/PrEC/PrEC.MD.strands_CpG.tsv.gz| cut -f5,6|head) \
# <(zcat /home/phuluu/data/WGBS10X_new/Test_Prostate/called/LNCaP/LNCaP.MD.strands_CpG.tsv.gz| cut -f5,6| head)
cmd=""" echo ${input/.MD_/.MD.strands_} > "$output/${sample}.MD.strands_CpG.merge" """
echo $cmd >> "$LOGFILE"; eval $cmd 2>> "$LOGFILE"; echo `date`" - Finished MD.strand_CpG.merge" >> $LOGFILE

echo `date`" - MD.strand_CHG.merge" >> $LOGFILE
# paste <(head /home/phuluu/Projects/WGBS10X_new/V02/annotations/hg19/hg19.CHG.strands.bed| cut -f1,3,6) \
# <(zcat /home/phuluu/data/WGBS10X_new/Test_Prostate/called/PrEC/PrEC.MD.strands_CHG.tsv.gz| cut -f5,6|head) \
# <(zcat /home/phuluu/data/WGBS10X_new/Test_Prostate/called/LNCaP/LNCaP.MD.strands_CHG.tsv.gz| cut -f5,6| head)
cmd=""" echo ${input/.MD_CpG/.MD.strands_CHG} > "$output/${sample}.MD.strands_CHG.merge" """
echo $cmd >> "$LOGFILE"; eval $cmd 2>> "$LOGFILE"; echo `date`" - MD.strand_CHG.merge" >> $LOGFILE

echo `date`" - MD.strand_CHH.merge" >> $LOGFILE
# paste <(head /home/phuluu/Projects/WGBS10X_new/V02/annotations/hg19/hg19.CHA.strands.bed| cut -f1,3,6) \
# <(zcat /home/phuluu/data/WGBS10X_new/Test_Prostate/called/PrEC/PrEC.MD.strands_CHA.tsv.gz| cut -f5,6|head) \
# <(zcat /home/phuluu/data/WGBS10X_new/Test_Prostate/called/LNCaP/LNCaP.MD.strands_CHA.tsv.gz| cut -f5,6| head)
cmd=""" echo ${input/.MD_CpG/.MD.strands_CHH} > "$output/${sample}.MD.strands_CHH.merge" """
echo $cmd >> "$LOGFILE"; eval $cmd 2>> "$LOGFILE"; echo `date`" - MD.strand_CHH.merge" >> $LOGFILE

# echo `date`" - MD.strand_CHC.merge" >> $LOGFILE
# # paste <(head /home/phuluu/Projects/WGBS10X_new/V02/annotations/hg19/hg19.CHC.strands.bed| cut -f1,3,6) \
# # <(zcat /home/phuluu/data/WGBS10X_new/Test_Prostate/called/PrEC/PrEC.MD.strands_CHC.tsv.gz| cut -f5,6|head) \
# # <(zcat /home/phuluu/data/WGBS10X_new/Test_Prostate/called/LNCaP/LNCaP.MD.strands_CHC.tsv.gz| cut -f5,6| head)
# cmd=""" echo ${input/.MD_CpG/.MD.strands_CHC} > "$output/${sample}.MD.strands_CHC.merge" """
# echo $cmd >> "$LOGFILE"; eval $cmd 2>> "$LOGFILE"; echo `date`" - MD.strand_CHC.merge" >> $LOGFILE

# echo `date`" - MD.strand_CHT.merge" >> $LOGFILE
# # paste <(head /home/phuluu/Projects/WGBS10X_new/V02/annotations/hg19/hg19.CHT.strands.bed| cut -f1,3,6) \
# # <(zcat /home/phuluu/data/WGBS10X_new/Test_Prostate/called/PrEC/PrEC.MD.strands_CHT.tsv.gz| cut -f5,6|head) \
# # <(zcat /home/phuluu/data/WGBS10X_new/Test_Prostate/called/LNCaP/LNCaP.MD.strands_CHT.tsv.gz| cut -f5,6| head)
# cmd=""" echo ${input/.MD_CpG/.MD.strands_CHT} > "$output/${sample}.MD.strands_CHT.merge" """
# echo $cmd >> "$LOGFILE"; eval $cmd 2>> "$LOGFILE"; echo `date`" - MD.strand_CHT.merge" >> $LOGFILE

echo `date`" - MD.lambda.merge" >> $LOGFILE
# paste <(head /home/phuluu/Projects/WGBS10X_new/V02/annotations/hg19/lambda.C.strands.bed| cut -f1,3,6) \
# <(zcat /home/phuluu/data/WGBS10X_new/Test_Prostate/called/PrEC/PrEC.MD.strands_lambda.bed| cut -f5,6|head) \
# <(zcat /home/phuluu/data/WGBS10X_new/Test_Prostate/called/LNCaP/LNCaP.MD.strands_lambda.bed| cut -f5,6| head)
cmd=""" echo ${input/.MD_CpG/.MD.strands_lambda} > "$output/${sample}.MD.strands_lambda.merge" """
echo $cmd >> "$LOGFILE"; eval $cmd 2>> "$LOGFILE"; echo `date`" - MD.lambda.merge" >> $LOGFILE

echo `date`" - BC.snp.vcf.merge" >> $LOGFILE
# module load phuluu/perl/5.24.1
# export PERL5LIB=/share/ClusterShare/software/contrib/phuluu/vcftools/src/perl/:$PERL5LIB
# /share/ClusterShare/software/contrib/phuluu/vcftools/bin/vcf-merge \
# /home/phuluu/data/WGBS10X_new/Test_Prostate/called/PrEC/PrEC.BC.snp.vcf.gz \
# /home/phuluu/data/WGBS10X_new/Test_Prostate/called/LNCaP/LNCaP.BC.snp.vcf.gz \
# > /home/phuluu/data/WGBS10X_new/Test_Prostate/bigTables/bigTable.BC.snp.vcf
cmd=""" echo ${input/.MD_CpG.tsv/.BC.snp.vcf} > "$output/${sample}.BC.snp.vcf.merge" """
echo $cmd >> "$LOGFILE"; eval $cmd 2>> "$LOGFILE"; echo `date`" - Finished BC.snp.vcf.merge" >> $LOGFILE

# plot bcftools stats
# module load phuluu/python/2.7.8
# /share/ClusterShare/software/contrib/phuluu/bcftools/bcftools stats \
# /home/phuluu/data/WGBS10X_new/Test_Prostate/bigTables/bigTable.BC.snp.vcf.gz > ~/file.vchk
# /share/ClusterShare/software/contrib/phuluu/bcftools/plot-vcfstats ~/file.vchk -p ~/out/
