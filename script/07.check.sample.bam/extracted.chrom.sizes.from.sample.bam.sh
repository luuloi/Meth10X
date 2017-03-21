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
LOGFILE="${OUTPUT}/${sample}.extract.chrom.sizes.log"

echo " *** Extracted chrom sizes from bam" >> $LOGFILE
echo `date`" - Started processing $INPUT on $HOSTNAME" >> $LOGFILE
echo """ samtools view -H $INPUTS | grep ^@SQ | tr "\t" ":" | awk -F: '{print $3"\t"$5}' > ${OUTPUT}/${sample}.chrom.sizes """ >> $LOGFILE
samtools view -H $INPUT | grep ^@SQ | tr "\t" ":" | awk -F: '{print $3"\t"$5}' > "${OUTPUT}/${sample}.chrom.sizes" 2>> $LOGFILE
echo `date`" - Finished Extracted chrom sizes from bam" >> $LOGFILE



