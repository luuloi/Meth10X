#!/bin/bash

# INPUTS="/home/darloluu/tmp/Test_Prostate/called/LNCaP/LNCaP.lambda.strand.tsv.gz /home/darloluu/tmp/Test_Prostate/called/PrEC/PrEC.lambda.strand.tsv.gz"
INPUTS=$1
# OUTPUT="/home/darloluu/tmp/Test_Prostate/bigTables"
OUTPUT=$2
# fname="bigTable.tsv.gz"
fname=$3
# COUNT=2
COUNT=$4

LOGFILE="${OUTPUT}/bigTables.merg.log"
echo "bigTables.merged.bash" > "$LOGFILE"
echo `date`" - Starting merge CpG tsv of all samples to bigTable on $1 with $HOSTNAME" >> "$LOGFILE"

if [[ $COUNT -gt 1 ]]; then
	# header
	header="chr\tposition"
	for i in $INPUTS;
	do
		sample=$(basename $(dirname $i));
		header="${header}\t${sample}.C\t${sample}.cov";
	done;
	echo -e "$header" | gzip -c > "$OUTPUT/$fname";
	# body
	pfname1=$(echo $INPUTS| cut -d ' ' -f1)
	cmd="paste <(gunzip -c $pfname1)"
	for i in $(seq 2 $COUNT);
	do
		pfname1=$(echo $INPUTS| cut -d ' ' -f$i)
		cmd="$cmd <(gunzip -c $pfname1| cut -f3,4)"; 
	done; 
	cmd="$cmd | gzip -c >> $OUTPUT/$fname";
	echo $cmd  >> "$LOGFILE";
	eval $cmd;
	gunzip -c "$OUTPUT/$fname" > "$OUTPUT/${fname/.gz/}";
else
	echo `cp $INPUTS "$OUTPUT/$fname"` >> "$LOGFILE";
	echo `gunzip -c "$OUTPUT/$fname" > "$OUTPUT/${fname/.gz/}"` >> "$LOGFILE";
fi
echo `date`" - Finished merging output" >> "$LOGFILE"
