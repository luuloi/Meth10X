#!/bin/bash -e

# load module 
export MODULEPATH=/share/ClusterShare/Modules/modulefiles/noarch:/share/ClusterShare/Modules/modulefiles/centos6.2_x86_64:/share/ClusterShare/Modules/modulefiles/contrib:$MODULEPATH 
source /etc/profile.d/modules.sh
module load gi/samtools/1.2

# $1=aligned/PrEC/PrEC.bam
INPUT=$1
sample=$(basename $INPUT| cut -d. -f1)
# $2=aligned/PrEC
OUTPUT=$2
LOGFILE="${OUTPUT}/${sample}.count.mapq.score.log"

echo " *** Count MAPQ score" > $LOGFILE
echo `date`" - Started processing $INPUT on $HOSTNAME" >> $LOGFILE
echo """ samtools view $INPUT| cut -f5 | sort -n | uniq -c > $OUTPUT/${sample}.mapq """ >> $LOGFILE
samtools view $INPUT| cut -f5 | sort -n | uniq -c > "$OUTPUT/${sample}.mapq" 2>> $LOGFILE
echo `date`" - Finished count MAPQ bam" >> $LOGFILE

