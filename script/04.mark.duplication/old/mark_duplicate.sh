#!/bin/bash -e

JAVA="java -Djava.io.tmpdir=/tmp"

Lane=$(echo $1| cut -d/ -f2)
INPUT=$(dirname $1)
OUTPUT=$2

LOGFILE=$OUTPUT/"$Lane".mark.duplicate.log


$JAVA -jar "$PICARD_HOME"/MarkDuplicates.jar I=$OUTPUT/"$Lane".align.bam O=$OUTPUT/"$Lane".bam M="$Lane".metrics REMOVE_DUPLICATES=FALSE AS=TRUE CREATE_INDEX=TRUE 2>> "$LOGFILE"


