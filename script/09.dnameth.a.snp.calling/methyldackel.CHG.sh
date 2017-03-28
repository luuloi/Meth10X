#!bin/bash -e
# usage: bash methyldackel.sh input output reference

# load module 
export MODULEPATH=/share/ClusterShare/Modules/modulefiles/noarch:/share/ClusterShare/Modules/modulefiles/centos6.2_x86_64:/share/ClusterShare/Modules/modulefiles/contrib:$MODULEPATH 
source /etc/profile.d/modules.sh
module load phuluu/python/2.7.8
module load phuluu/pigz/2.3.4


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
BASEDIR=`readlink -f "${0%/*}"`

LOGFILE="${output}/${sample}.methyldackel.meth.calling.CHG.log"

echo `date`" - CHG strands" > $LOGFILE
# python methydackel.CHG.py sample_CHG g_CHG o_CHG sample
cmd="""
python $BASEDIR/methyldackel.CHG.py ${output}/${sample}.MD.strands_CHG.bedGraph ${GENOME/.fa/.CHG.strands.bed} ${output}/${sample}.MD.strands_CHG.tsv $sample
"""
echo $cmd >> "$LOGFILE"; eval $cmd 2>> "$LOGFILE"; echo -e `date`" Finished - CHG strands\n" >> $LOGFILE

echo "*** Zip output file"  >> $LOGFILE
cmd="""
pigz ${output}/${sample}.MD.strands_CHG.tsv;
"""
echo $cmd >> "$LOGFILE"; eval $cmd 2>> "$LOGFILE"; echo -e `date`" Zip output\n" >> $LOGFILE
