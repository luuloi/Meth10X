#!/bin/bash -e

# load module 
export MODULEPATH=/share/ClusterShare/Modules/modulefiles/noarch:/share/ClusterShare/Modules/modulefiles/centos6.2_x86_64:/share/ClusterShare/Modules/modulefiles/contrib:$MODULEPATH 
export PATH=/home/phuluu/bin:$PATH
source /etc/profile.d/modules.sh
module load phuluu/python/2.7.8
module load gi/samtools/1.2

# $1=aligned/PrEC/TKCC20140214_PrEC_P6_Test_trimmed/TKCC20140214_PrEC_P6_Test_trimmed.bam
Lane=$(basename $1| cut -d. -f1)
# $2=aligned/PrEC/TKCC20140214_PrEC_P6_Test_trimmed/
OUTPUT=$2
# /home/darloluu/methods/darlo/annotations/hg19/hg19.fa
GENOME=$3
# bwameth
BWAMETH="/share/ClusterShare/software/contrib/phuluu/bwa-meth"
LOGFILE=$OUTPUT/"$Lane".compute.statistics.log

# compute statistics
echo `date`" - Compute statistics" > "$LOGFILE"
samtools flagstat $1 > $OUTPUT/"$Lane".flagstat

echo `date`" - Assessing bias" >> "$LOGFILE"
python "$BWAMETH"/bias-plot.py $1 "$GENOME" 2>> "$LOGFILE"

echo `date`" - Finished compute statistics" >> "$LOGFILE"
