#!/bin/bash -e

# run this script
# bash ~/Projects/WGBS10X_new/V02/script/09.dnameth.a.snp.calling/MethylSeekR.sh aligned/PrEC/PrEC.bam called/PrEC /home/phuluu/Projects/WGBS10X_new/V02/annotations/hg19/hg19.fa

# load module 
export MODULEPATH=/share/ClusterShare/Modules/modulefiles/noarch:/share/ClusterShare/Modules/modulefiles/centos6.2_x86_64:/share/ClusterShare/Modules/modulefiles/contrib:$MODULEPATH 
source /etc/profile.d/modules.sh
module load phuluu/R/3.1.2
# bedToBigBed
module load phuluu/UCSC/v4


# get paramaters
# $1=called/PrEC/PrEC.MD_CpG.tsv.gz
sample=$(basename $1| cut -d. -f1)
input=${1/.gz/}
# $2=bigTable/bw/MethylSeekR/
output=$2
# GENOME="/home/phuluu/methods/darlo/annotations/hg19/hg19.fa"
GENOME=$3
build_name=$(basename $GENOME| cut -d. -f1)
annotation_prefix=$(dirname $GENOME)
BASEDIR=`readlink -f "${0%/*}"`
# # example
# input="/home/phuluu/data/WGBS10X_new/Test_Prostate/merged/PrEC/PrEC.bam"
# sample="PrEC"
# output="/home/phuluu/data/WGBS10X_new/Test_Prostate/called/PrEC/"
# GENOME="/home/phuluu/Projects/WGBS10X_new/V02/annotations/hg19/hg19.fa"
LOGFILE="bigTable/bw/MethylSeekR/${sample}.MethylSeekR.log"

echo `date`" *** MethylSeekR " > $LOGFILE
# R -f MethylSeekR.R --args build.name annotation.prefix bigTable.path output.dir sample
# R -f ~/Projects/WGBS10X_new/V02/script/09.dnameth.a.snp.calling/MethylSeekR.R --args hg19 \
# 																					   /home/phuluu/Projects/WGBS10X_new/V02/annotations/hg19/ \
# 																					   called/PrEC/PrEC.MD_CpG.tsv \
# 																					   bigTable/bw/MethylSeekR/ \
# 																					   PrEC
cmd="""
`which R` -f $BASEDIR/MethylSeekR.R --args $build_name $annotation_prefix $input $output $sample
"""
echo $cmd >> $LOGFILE; eval $cmd 2>> $LOGFILE; echo -e `date`" Finished - MethylSeekR\n" >> $LOGFILE
