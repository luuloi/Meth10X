#!/bin/bash -e

# bash "/home/phuluu/Projects/WGBS10X_new/V02//script/07.check.sample.bam/clip.bam.sh" "merged/LNCaP/LNCaP.bam" "/home/phuluu/data/WGBS10X_new/Test_Prostate/merged/LNCaP"
# load module 
export MODULEPATH=/share/ClusterShare/Modules/modulefiles/noarch:/share/ClusterShare/Modules/modulefiles/centos6.2_x86_64:/share/ClusterShare/Modules/modulefiles/contrib:$MODULEPATH 
export PATH=/home/phuluu/bin:$PATH
source /etc/profile.d/modules.sh
module load marcow/bamUtil/gcc-4.4.6/1.0.7

# $1=aligned/PrEC/PrEC.bam
INPUT=$1
sample=$(basename $INPUT| cut -d. -f1)
# $2=aligned/PrEC
OUTPUT=$2
LOGFILE="${OUTPUT}/${sample}.clip.bam.log"

echo " *** Clipping bam" > $LOGFILE
echo `date`" - Started processing $INPUT on $HOSTNAME" >> $LOGFILE
echo """ bam clipOverlap --in $INPUT --poolSize 100000000 --out $OUTPUT/${sample}.clip.bam """ >> $LOGFILE
bam clipOverlap --in $INPUT --poolSize 100000000 --out "$OUTPUT/${sample}.clip.bam" 2>> $LOGFILE
echo `date`" - Finished clipping bam" >> $LOGFILE


