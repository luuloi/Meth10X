#!bin/bash -e
# usage: bash methyldackel.sh input output reference


# get paramaters
# $1=called/PrEC/PrEC.MD_CpG.bed.gz
input=$1
sample=$(basename $input| cut -d. -f1)
# $2=bigTables/bw
output=$2


# 'MD_CpG.merge'
# paste <(head /home/phuluu/Projects/WGBS10X_new/V02/annotations/hg19/hg19.CpG.bed| cut -f1,3,6) \
# <(zcat /home/phuluu/data/WGBS10X_new/Test_Prostate/called/PrEC/PrEC.MD_CpG.bed.gz| cut -f5,6|head) \
# <(zcat /home/phuluu/data/WGBS10X_new/Test_Prostate/called/LNCaP/LNCaP.MD_CpG.bed.gz| cut -f5,6| head)
echo <(zcat $input| cut -f4,5) >> $output/MD_CpG.merge 

# 'MD.strand_CpG.merge'
# paste <(head /home/phuluu/Projects/WGBS10X_new/V02/annotations/hg19/hg19.CpG.strands.bed| cut -f1,3,6) \
# <(zcat /home/phuluu/data/WGBS10X_new/Test_Prostate/called/PrEC/PrEC.MD.strands_CpG.bed.gz| cut -f5,6|head) \
# <(zcat /home/phuluu/data/WGBS10X_new/Test_Prostate/called/LNCaP/LNCaP.MD.strands_CpG.bed.gz| cut -f5,6| head)

# 'MD.strand_CHG.merge'
# paste <(head /home/phuluu/Projects/WGBS10X_new/V02/annotations/hg19/hg19.CHG.strands.bed| cut -f1,3,6) \
# <(zcat /home/phuluu/data/WGBS10X_new/Test_Prostate/called/PrEC/PrEC.MD.strands_CHG.bed.gz| cut -f5,6|head) \
# <(zcat /home/phuluu/data/WGBS10X_new/Test_Prostate/called/LNCaP/LNCaP.MD.strands_CHG.bed.gz| cut -f5,6| head)

# 'MD.strand_CHA.merge'
# paste <(head /home/phuluu/Projects/WGBS10X_new/V02/annotations/hg19/hg19.CHA.strands.bed| cut -f1,3,6) \
# <(zcat /home/phuluu/data/WGBS10X_new/Test_Prostate/called/PrEC/PrEC.MD.strands_CHA.bed.gz| cut -f5,6|head) \
# <(zcat /home/phuluu/data/WGBS10X_new/Test_Prostate/called/LNCaP/LNCaP.MD.strands_CHA.bed.gz| cut -f5,6| head)

# 'MD.strand_CHC.merge'
# paste <(head /home/phuluu/Projects/WGBS10X_new/V02/annotations/hg19/hg19.CHC.strands.bed| cut -f1,3,6) \
# <(zcat /home/phuluu/data/WGBS10X_new/Test_Prostate/called/PrEC/PrEC.MD.strands_CHC.bed.gz| cut -f5,6|head) \
# <(zcat /home/phuluu/data/WGBS10X_new/Test_Prostate/called/LNCaP/LNCaP.MD.strands_CHC.bed.gz| cut -f5,6| head)

# 'MD.strand_CHT.merge'
# paste <(head /home/phuluu/Projects/WGBS10X_new/V02/annotations/hg19/hg19.CHT.strands.bed| cut -f1,3,6) \
# <(zcat /home/phuluu/data/WGBS10X_new/Test_Prostate/called/PrEC/PrEC.MD.strands_CHT.bed.gz| cut -f5,6|head) \
# <(zcat /home/phuluu/data/WGBS10X_new/Test_Prostate/called/LNCaP/LNCaP.MD.strands_CHT.bed.gz| cut -f5,6| head)

# "MD.lambda.merge"
# paste <(head /home/phuluu/Projects/WGBS10X_new/V02/annotations/hg19/lambda.C.strands.bed| cut -f1,3,6) \
# <(zcat /home/phuluu/data/WGBS10X_new/Test_Prostate/called/PrEC/PrEC.MD.strands_lambda.bed| cut -f5,6|head) \
# <(zcat /home/phuluu/data/WGBS10X_new/Test_Prostate/called/LNCaP/LNCaP.MD.strands_lambda.bed| cut -f5,6| head)

# "BC.snp.vcf.merge"
# module load phuluu/perl/5.24.1
# export PERL5LIB=/share/ClusterShare/software/contrib/phuluu/vcftools/src/perl/:$PERL5LIB
# /share/ClusterShare/software/contrib/phuluu/vcftools/bin/vcf-merge \
# /home/phuluu/data/WGBS10X_new/Test_Prostate/called/PrEC/PrEC.BC.snp.vcf.gz \
# /home/phuluu/data/WGBS10X_new/Test_Prostate/called/LNCaP/LNCaP.BC.snp.vcf.gz \
# > /home/phuluu/data/WGBS10X_new/Test_Prostate/bigTables/bigTable.BC.snp.vcf

# plot bcftools stats
# module load phuluu/python/2.7.8
# /share/ClusterShare/software/contrib/phuluu/bcftools/bcftools stats \
# /home/phuluu/data/WGBS10X_new/Test_Prostate/bigTables/bigTable.BC.snp.vcf.gz > ~/file.vchk
# /share/ClusterShare/software/contrib/phuluu/bcftools/plot-vcfstats ~/file.vchk -p ~/out/
