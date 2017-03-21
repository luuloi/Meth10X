#!/bin/bash -e

# load module 
export MODULEPATH=/share/ClusterShare/Modules/modulefiles/noarch:/share/ClusterShare/Modules/modulefiles/centos6.2_x86_64:/share/ClusterShare/Modules/modulefiles/contrib:$MODULEPATH 
export PATH=/home/phuluu/bin:$PATH
unset DISPLAY
source /etc/profile.d/modules.sh
module load gi/java/jdk1.8.0_25
module load gi/qualimap/1.0
module load gi/samtools/1.2
module load gi/samstat/1.08
module load phuluu/python/2.7.8

# $1=aligned/PrEC/PrEC.bam
INPUT=$1
sample=$(basename $INPUT| cut -d. -f1)
# $2=aligned/PrEC
OUTPUT=$2
BASEDIR=`readlink -f "${0%/*}"`

LOGFILE="${OUTPUT}/${sample}.qualimap.log"
echo `date`" *** Created Qualimap" > $LOGFILE
echo """ mkdir -p $OUTPUT """ >> $LOGFILE 
mkdir -p $OUTPUT 2>> $LOGFILE

echo """ qualimap bamqc -bam $1 -gd HUMAN -outdir $OUTPUT -nt 4 -nr 10000 """ >> $LOGFILE
qualimap bamqc -bam $1 -gd HUMAN -outdir $OUTPUT -nt 4 -nr 10000 2>> $LOGFILE

# python coverage.vs.depth.whole.genome.py genome_results.txt genome_coverage.tsv sample
# echo python "$BASEDIR/coverage.vs.depth.whole.genome.py" "${OUTPUT}/QC/genome_results.txt" "${OUTPUT}/QC/genome_coverage.tsv" "$sample" >> $LOGFILE  
# python "$BASEDIR/coverage.vs.depth.whole.genome.py" "${OUTPUT}/QC/genome_results.txt" "${OUTPUT}/QC/genome_coverage.tsv" "$sample" 2>> $LOGFILE

echo "samtools view -ub $INPUT | samstat -f bam -n ${INPUT/.bam/}" >> $LOGFILE
samtools view -ub $INPUT | samstat -f bam -n ${INPUT/.bam/} 2>> $LOGFILE

echo mv "${INPUT/.bam/}.html" "$OUTPUT/$(basename ${INPUT/.bam/}).html" >> $LOGFILE
mv "${INPUT/.bam/}.html" "$OUTPUT/$(basename ${INPUT/.bam/}).html" 2>> $LOGFILE

echo `date`" - Finished created Qualimap" >> $LOGFILE


