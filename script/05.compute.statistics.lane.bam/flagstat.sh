#!/bin/bash -e

# load module 
export MODULEPATH=/share/ClusterShare/Modules/modulefiles/noarch:/share/ClusterShare/Modules/modulefiles/centos6.2_x86_64:/share/ClusterShare/Modules/modulefiles/contrib:$MODULEPATH 
source /etc/profile.d/modules.sh
module load gi/samtools/1.2

# $1=aligned/PrEC/TKCC20140214_PrEC_P6_Test_trimmed/TKCC20140214_PrEC_P6_Test_trimmed.bam
INPUT=$1
Lane=$(basename $INPUT| cut -d. -f1)
# $2=aligned/PrEC/TKCC20140214_PrEC_P6_Test_trimmed/
OUTPUT=$2
LOGFILE="$OUTPUT/${Lane}.flagstat.log"

echo " *** Samtools Flagstat" > $LOGFILE
echo `date`" - Started processing $INPUT on $HOSTNAME" >> $LOGFILE
echo samtools flagstat $INPUT > "$OUTPUT/${Lane}.flagstat" >> $LOGFILE 
samtools flagstat $INPUT > "$OUTPUT/${Lane}.flagstat" 2>> $LOGFILE
echo `date`" - Finished compute statistics" >> $LOGFILE


