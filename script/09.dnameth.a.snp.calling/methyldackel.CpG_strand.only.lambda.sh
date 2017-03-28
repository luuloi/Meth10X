#!bin/bash -e
# usage: bash methyldackel.sh input output reference

# load module 
export MODULEPATH=/share/ClusterShare/Modules/modulefiles/noarch:/share/ClusterShare/Modules/modulefiles/centos6.2_x86_64:/share/ClusterShare/Modules/modulefiles/contrib:$MODULEPATH
source /etc/profile.d/modules.sh
module load gi/bedtools/2.22.0
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

LOGFILE="${output}/${sample}.methyldackel.CpG_strand.only.lambda.log"

##### lambda
echo `date`" - Lambda in CpG strands" > $LOGFILE
echo " - Get only lambda from MethylDackel strands output" >> $LOGFILE
cmd="""
grep lambda ${output}/${sample}.MD.strands_CpG.bedGraph ${output}/${sample}.MD.strands_CHG.bedGraph ${output}/${sample}.MD.strands_CHH.bedGraph| cut -d: -f2| sort -k2,2n > ${output}/${sample}.MD.strands_lambda.bedGraph
"""
echo $cmd >> "$LOGFILE"; eval $cmd 2>> "$LOGFILE"

echo " - Check lambda file has any rows?" >> "$LOGFILE"
cmd="""nrow=\$(wc -l ${output}/${sample}.MD.strands_lambda.bedGraph| awk '{print \$1}') """
echo $cmd >> "$LOGFILE"; eval $cmd 2>> "$LOGFILE"
# ${output}/${sample}.MD.strands_lambda.bedGraph
# lambda  3 4 0 0 1
# lambda  6 7 0 0 1
cmd="""
if [ $nrow -lt 2 ]; then
  echo -e \"lambda\t1\t2\t0\t0\t0\" > ${output}/${sample}.MD.strands_lambda.bedGraph;
fi
"""
echo $cmd >> "$LOGFILE"; eval $cmd 2>> "$LOGFILE"

echo -e "chr\tposition\tstrand\t${sample}.C\t${sample}.cov" > "${output}/${sample}.MD.strands_lambda.tsv"
# zcat MCF7.lambda.strand.tsv.gz| head -n 3
# chr     position  strand  MCF7.C  MCF7.cov
# lambda  1         -       0       0
# lambda  2         -       0       0

cmd="""
bedtools intersect -a ${GENOME/hg19.fa/lambda.C.strands.bed} -b ${output}/${sample}.MD.strands_lambda.bedGraph -loj| awk '{OFS=\"\t\"}{if(\$11==-1){\$11=\$12=0}; print \$1,\$3,\$6,\$11,\$11+\$12}' >> ${output}/${sample}.MD.strands_lambda.tsv
"""
echo $cmd >> "$LOGFILE"; eval $cmd 2>> "$LOGFILE"; echo -e `date`" Finished - lambda strands\n" >> $LOGFILE


echo "*** Zip output file"  >> $LOGFILE
cmd="""
gzip ${output}/${sample}.MD.strands_lambda.tsv;
"""
echo $cmd >> "$LOGFILE"; eval $cmd 2>> "$LOGFILE"; echo -e `date`" Zip output\n" >> $LOGFILE

