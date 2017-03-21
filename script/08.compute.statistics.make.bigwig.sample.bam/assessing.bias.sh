#!/bin/bash -e

# load module 
export MODULEPATH=/share/ClusterShare/Modules/modulefiles/noarch:/share/ClusterShare/Modules/modulefiles/centos6.2_x86_64:/share/ClusterShare/Modules/modulefiles/contrib:$MODULEPATH 
export PATH=/home/phuluu/bin:$PATH
source /etc/profile.d/modules.sh
MethylDackel="/home/phuluu/methods/DNAmeth.calling.method.comparison/MethylDackel/bin/MethylDackel"
# module load phuluu/python/2.7.8

# $1=aligned/PrEC/PrEC.bam
INPUT=$1
sample=$(basename $INPUT| cut -d. -f1)
# $2=aligned/PrEC/
OUTPUT=$2
# /home/darloluu/methods/darlo/annotations/hg19/hg19.fa
GENOME=$3
# bwameth
# BWAMETH="/share/ClusterShare/software/contrib/phuluu/bwa-meth"
LOGFILE="$OUTPUT/${sample}.assessing.bias.log"

echo " *** Assessing CpG Bias" > $LOGFILE
echo `date`" - Started processing $INPUT on $HOSTNAME" >> $LOGFILE
# echo python "$BWAMETH/bias-plot.py" $INPUT $GENOME >> $LOGFILE
# python "$BWAMETH/bias-plot.py" $INPUT $GENOME 2>> $LOGFILE
echo """ $MethylDackel mbias $GENOME $INPUT $OUTPUT/${sample}.MD.bias > $OUTPUT/${sample}.MD.bias.txt 2>&1 """ >> $LOGFILE
$MethylDackel mbias $GENOME $INPUT $OUTPUT/${sample}.MD.bias > $OUTPUT/${sample}.MD.bias.txt 2>&1
echo `date`" - Finished Assessing bias" >> $LOGFILE

