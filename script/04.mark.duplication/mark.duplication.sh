#!/bin/bash -e

# load module 
export MODULEPATH=/share/ClusterShare/Modules/modulefiles/noarch:/share/ClusterShare/Modules/modulefiles/centos6.2_x86_64:/share/ClusterShare/Modules/modulefiles/contrib:$MODULEPATH 
export PATH=/home/phuluu/bin:$PATH
source /etc/profile.d/modules.sh
module load gi/java/jdk1.8.0_25
module load phuluu/picard-tools/2.3.0

# $1==aligned/PrEC/TKCC20140123_PrEC_P6_Test_trimmed/TKCC20140123_PrEC_P6_Test_trimmed.align.bam
PICARD_HOME="$(dirname $(which picard.jar))"
JAVA="java -Xmx80g -Djava.io.tmpdir=/tmp"
Lane=$(basename $1| cut -d. -f1)
OUTPUT=$2
LOGFILE="$OUTPUT/${Lane}.mark.duplicate.log"

echo "WGBS10X mark.duplicate.sh" > $LOGFILE
echo `date`" - Started processing $1 on $HOSTNAME" >> $LOGFILE
echo $JAVA -jar "$PICARD_HOME/picard.jar" MarkDuplicates I=$1 O="$OUTPUT/${Lane}.bam" M="$OUTPUT/${Lane}.metrics" REMOVE_DUPLICATES=FALSE AS=TRUE CREATE_INDEX=TRUE >> $LOGFILE
$JAVA -jar "$PICARD_HOME/picard.jar" MarkDuplicates I=$1 O="$OUTPUT/${Lane}.bam" M="$OUTPUT/${Lane}.metrics" REMOVE_DUPLICATES=FALSE AS=TRUE CREATE_INDEX=TRUE 2>> $LOGFILE
echo `date`" - Finished mark duplicate" >> "$LOGFILE"


