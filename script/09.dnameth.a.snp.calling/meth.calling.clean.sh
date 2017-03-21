#!bin/bash -e
# usage: bash methyldackel.sh input output reference

export MODULEPATH=/share/ClusterShare/Modules/modulefiles/noarch:/share/ClusterShare/Modules/modulefiles/centos6.2_x86_64:/share/ClusterShare/Modules/modulefiles/contrib:$MODULEPATH
source /etc/profile.d/modules.sh

# get paramaters
# $1=aligned/PrEC/PrEC.bam
input=$1
sample=$(basename $input| cut -d. -f1)
# $2=calls/PrEC
output=$2
# GENOME="/home/phuluu/methods/darlo/annotations/hg19/hg19.fa"
GENOME=$3
# # example
# input="/home/phuluu/data/WGBS10X_new/Test_Prostate/merged/PrEC/PrEC.bam"
# sample="PrEC"
# output="/home/phuluu/data/WGBS10X_new/Test_Prostate/called/PrEC/"
# GENOME="/home/phuluu/Projects/WGBS10X_new/V02/annotations/hg19/hg19.fa"

LOGFILE="${output}/${sample}.meth.calling.clean.log"

echo "*** Clean up" > $LOGFILE
# rm "${output}/${sample}.BC.snp.bed";
cmd="""
rm "${output}/${sample}.MD.strands_C*.bedGraph";
rm "${output}/${sample}.MD.strands_lambda.bedGraph";
rm "${output}/${sample}.MD_C*.bedGraph";
rm "${output}/${sample}.MD_CpG.tsv";
"""
echo $cmd >> "$LOGFILE"; eval $cmd 2>> "$LOGFILE"
echo `date`" - Finished DNA methylation/SNP calling with MethylDackel and Biscuit" >> $LOGFILE
