#!bin/bash -e
# usage: bash methyldackel.sh input output reference

# load module 
export MODULEPATH=/share/ClusterShare/Modules/modulefiles/noarch:/share/ClusterShare/Modules/modulefiles/centos6.2_x86_64:/share/ClusterShare/Modules/modulefiles/contrib:$MODULEPATH
source /etc/profile.d/modules.sh
BASEDIR=`readlink -f "${0%/*}"`

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

LOGFILE="${output}/${sample}.methyldackel.CpG_strand.make.full.frame.log"

echo " *** Convert CpG strands bedGraph to bed" > $LOGFILE
echo `date`" - CpG strands" >> $LOGFILE
# chr     position  strand  MCF7.C  MCF7.cov
# chr1    10469     +       0       0
# chr1    10470     -       6       7
# python methydackel.CpG_strand.py sample_CpG_strand g_CpG_strand o_CpG_strand sample
cmd="""
python $BASEDIR/methyldackel.CpG_strand.py ${output}/${sample}.MD.strands_CpG.bedGraph ${GENOME/.fa/.CpG.strands.bed} ${output}/${sample}.MD.strands_CpG.tsv $sample
"""
echo $cmd >> "$LOGFILE"; eval $cmd 2>> "$LOGFILE"; echo -e `date`" Finished - CpG strands\n" >> $LOGFILE

echo "*** Zip output file"  >> $LOGFILE
cmd="""
gzip ${output}/${sample}.MD.strands_CpG.tsv;
"""
echo $cmd >> "$LOGFILE"; eval $cmd 2>> "$LOGFILE"; echo -e `date`" Zip output\n" >> $LOGFILE
