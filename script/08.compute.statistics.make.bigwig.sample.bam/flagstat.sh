#!/bin/bash -e

# load module 
export MODULEPATH=/share/ClusterShare/Modules/modulefiles/noarch:/share/ClusterShare/Modules/modulefiles/centos6.2_x86_64:/share/ClusterShare/Modules/modulefiles/contrib:$MODULEPATH 
export PATH=/home/phuluu/bin:$PATH
source /etc/profile.d/modules.sh
module load gi/samtools/1.2

# $1=aligned/PrEC/PrEC.bam
INPUT=$1
sample=$(basename $INPUT| cut -d. -f1)
# $2=aligned/PrEC/
OUTPUT=$2
LOGFILE="$OUTPUT/${sample}.flagstat.log"

echo " *** Samtools Flagstat" > $LOGFILE
echo `date`" - Started processing $INPUT on $HOSTNAME" >> $LOGFILE
echo samtools flagstat $INPUT > "$OUTPUT/${sample}.flagstat" >> $LOGFILE 
samtools flagstat $INPUT > "$OUTPUT/${sample}.flagstat" 2>> $LOGFILE
echo `date`" - Finished compute statistics" >> $LOGFILE


