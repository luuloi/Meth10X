#!/bin/bash

# load module 
export MODULEPATH=/share/ClusterShare/Modules/modulefiles/noarch:/share/ClusterShare/Modules/modulefiles/centos6.2_x86_64:/share/ClusterShare/Modules/modulefiles/contrib:$MODULEPATH
source /etc/profile.d/modules.sh
module load gi/java/jdk1.8.0_25
module load gi/samtools/1.2
module load phuluu/picard-tools/2.3.0

PICARD_HOME="$(dirname $(which picard.jar))"
JAVA="java -Xmx50g -Djava.io.tmpdir=/tmp"

# inputs
# $1==/home/phuluu/data/WGBS10X_new/Test_Prostate/aligned/LNCaP/LNCaP.move
sample=$(basename ${1/.move/})


# get all lane bam file names which are uniqued the lane bam filename 
count=0
for i in $(sort -u $1); do INPUTS=$INPUTS" I=$i"; count=$(($count+1)); done;

# output
# $2==merged/LNCaP/
OUTPUT=$2
mkdir -p $OUTPUT

# log
LOGFILE="${OUTPUT}/${sample}.merge.log"
bamfile="$OUTPUT/${sample}.bam"

echo `date`" - Started processing $1 on $HOSTNAME" > $LOGFILE
echo " *** Merge lane bams into sample bam" >> $LOGFILE 
echo "Inputs files: $INPUTS" >> $LOGFILE
if [[ $count -gt 1 ]]; then
	echo $JAVA -jar "$PICARD_HOME/picard.jar" MergeSamFiles USE_THREADING=true $INPUTS O="$OUTPUT/${sample}.bam" >> $LOGFILE
	$JAVA -jar "$PICARD_HOME/picard.jar" MergeSamFiles USE_THREADING=true $INPUTS O="$OUTPUT/${sample}.bam" 2>> $LOGFILE
elif [[ $count -eq 1 ]]; then
	echo "Since there is only one bam file, so no need to merge, only need to copy the file" >> $LOGFILE
	echo cp ${INPUTS// I=/} "$OUTPUT/${sample}.bam" >> $LOGFILE
	cp ${INPUTS// I=/} "$OUTPUT/${sample}.bam" 2>> $LOGFILE
else
	echo "Error, there is no bam files"
fi
echo " *** Index sample bam file" >> $LOGFILE
echo samtools index "$OUTPUT/${sample}.bam" >> $LOGFILE
samtools index "$OUTPUT/${sample}.bam" 2>> $LOGFILE
# echo mv "$OUTPUT/${sample}.bai" "$OUTPUT/${sample}.bam.bai" >> $LOGFILE
# mv "$OUTPUT/${sample}.bai" "$OUTPUT/${sample}.bam.bai" 2>> $LOGFILE
echo `date`" - Finished merge and index bam" >> $LOGFILE

