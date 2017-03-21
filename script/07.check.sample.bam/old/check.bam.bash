#!/bin/bash -e
# load module 
export MODULEPATH=/share/ClusterShare/Modules/modulefiles/noarch:/share/ClusterShare/Modules/modulefiles/centos6.2_x86_64:/share/ClusterShare/Modules/modulefiles/contrib:$MODULEPATH 
export PATH=/home/phuluu/bin:$PATH
source /etc/profile.d/modules.sh

BEDGRAPH="/home/darloluu/bin/ucsc/bedGraphToBigWig"
LOGFILE=${1}.check.bam.log

echo `date`" - Started processing $1 on $HOSTNAME" > $LOGFILE
echo samtools index $1 >> $LOGFILE
samtools index $1
echo mv "${1}.bai" "${1/.bam/.bai}" >> $LOGFILE
mv "${1}.bai" "${1/.bam/.bai}"
echo `date`" - Count MAPQ score" >> $LOGFILE
echo """samtools view $1| cut -f5 | sort -n | uniq -c > ${1/.bam/.mapq} """ >> $LOGFILE
samtools view $1| cut -f5 | sort -n | uniq -c > ${1/.bam/.mapq}
echo `date`" - End check bam" >> $LOGFILE
 