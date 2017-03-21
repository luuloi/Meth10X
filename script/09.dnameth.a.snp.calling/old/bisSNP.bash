#!/bin/bash -e
if [ $# -lt 3 ]
then
  echo "Usage: `basename $0` {Sample} {Genome} {No of 5' Bases to trim}"
  exit 1
fi

module load kevyin/java/1.7.0_25
BASEPATH=$(dirname $0)
JAVA="java -Djava.io.tmpdir=/tmp"
bam=$1
OUTPUT=$2
sample=$(basename $OUTPUT)
LOGFILE="$OUTPUT/$sample".bissnp.log
GENOME=$3
# "1,1"
trim=$4
NOMe="--context all"

echo "bisSNP.sh" > "$LOGFILE"
echo `date`" - Starting bissnp on $1 on $HOSTNAME" >> "$LOGFILE"
echo """bwameth.py tabulate --bissnp $BASEPATH/BisSNP-0.82.2.jar --trim $trim --map-q 60 --threads 32 --prefix $OUTPUT/$sample.bissnp --reference $GENOME $NOMe $bam """ >> "$LOGFILE" 
bwameth.py tabulate \
--trim "$trim" \
--bissnp $BASEPATH/BisSNP-0.82.2.jar \
--map-q 60 \
--threads 32 \
--prefix "$OUTPUT/$sample".bissnp \
--reference "$GENOME" \
$NOMe \
$bam 1>&2 >> "$LOGFILE"

echo `date`" - Compressing output" >> "$LOGFILE"
gzip $OUTPUT/*.vcf $OUTPUT/*.bed

echo `date`" - Finished pipeline" >> "$LOGFILE"
