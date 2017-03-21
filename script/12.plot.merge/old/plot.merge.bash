#!bin/bash

module load gi/bedtools/2.22.0
module load phuluu/R/3.1.2

BASEDIR=$(dirname $0)
# INPUT="/home/darloluu/tmp/Test_Prostate/bigTables/bigTable.tsv.gz"
input=$1
# OUTPUT="/home/darloluu/tmp/Test_Prostate/bigTables/QC"
output=$2

LOGFILE="$output/plot.merge.log"

echo "plot.merge.bash" > "$LOGFILE"
echo "Decompress gz file" >> "$LOGFILE"
gunzip < $input > ${input/.gz/} 2>> "$LOGFILE"
echo `date`" - Started processing $1 on $HOSTNAME" >> "$LOGFILE"
echo `date`" - MDS plot for single CpG sites, smoothed 100bp, 1kb, 10kb, 100kb; whole genome CpG coverage for all samples and merge CpG bias " >> "$LOGFILE"
Rscript "$BASEDIR/plot.merge.r" "${input/.gz/}" "$output" 2>> "$LOGFILE"
echo `date`" - Finished the processing" >> "$LOGFILE"
