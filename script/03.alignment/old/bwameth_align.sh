#!/bin/bash -e
if [ $# -lt 2 ]
then
  echo "Usage: `basename $0` {Forward_Read_path} {Reverse_Read_path} {Genome} {Output_path} [-s SampleName] [-d Do not MarkDuplicates] [-n Sort by read name] [-c Clip overlaps]"
  exit 1
fi

echo "darlo alignment/bwameth_align.sh"
echo `date`" - Started processing $1 on $HOSTNAME"

Ncores=8

# Get initial unnamed arguments
Lane=$(echo $1| cut -d/ -f2)
INPUT=$(dirname $1)
FW=$1
RV=$2
GENOME=$3
OUTPUT=$4

# Set argument defaults
SampleName=${Lane/_0?_trimmed/}
MarkDuplicates=0
Name=0
Clip=0

# Parse the named arguments
while getopts ":s:t:Sdnc" OPTION ${@:3}; do
	case $OPTION in
		s)	SampleName=$OPTARG 
			;;
		d)	MarkDuplicates=0
			;;
		n)	Name=1
			;;
		c)	Clip=1
			;;
		\?)	echo "Unknown option: -$OPTARG" >&2
			exit 1
			;;
		:)	echo "Option -$OPTARG requires an argument." >&2 
			exit 1
			;;
	esac
done

JAVA="java -Djava.io.tmpdir=/tmp"
VERSION="1.0.0"
LOGFILE=$OUTPUT/"$Lane".alignment.log

echo "darlo alignment/bwameth_align.sh"
echo "Bisulfite alignment Version $VERSION" > "$LOGFILE"

if [[ -e $INPUT/"$Lane".fastq.gz ]]
then
	echo "Single end alignment of ""$Lane" >> "$LOGFILE"
    Paired=0
elif [[ -e $INPUT/"$Lane"_R1.fastq.gz ]]
then
	echo "Paired end alignment of ""$Lane" >> "$LOGFILE"
    Paired=1
else
	echo "Error - ""$Lane"" files not found" >> "$LOGFILE"
	exit 1
fi

echo `date`" - Starting alignment" >> "$LOGFILE"
if [[ "$Paired" -gt 0 ]]
then
	bwameth.py --threads $Ncores --prefix $OUTPUT/"$Lane".align --read-group @RG\\tID:"$Lane"\\tSM:"$SampleName" --reference "$GENOME" "$FW" "$RV" 1>&2 >> "$LOGFILE"
else
	bwameth.py --threads $Ncores --prefix $OUTPUT/"$Lane".align --read-group @RG\\tID:"$Lane"\\tSM:"$SampleName" --reference "$GENOME" "$FW" 1>&2 >> "$LOGFILE"
fi

if [[ "$MarkDuplicates" -gt 0 ]]
then
	echo `date`" - Marking duplicates" >> "$LOGFILE"
	$JAVA -jar "$PICARD_HOME"/MarkDuplicates.jar I=$OUTPUT/"$Lane".align.bam O=$OUTPUT/"$Lane".bam M="$Lane".metrics REMOVE_DUPLICATES=FALSE AS=TRUE CREATE_INDEX=TRUE 1>&2 >> "$LOGFILE"
fi

if [[ "$Name" -gt 0 ]]
then
	samtools sort -n $OUTPUT/"$Lane".bam $OUTPUT/"$Lane".name
	if  [[ "$Clip" -gt 0 ]]
	then
		module load marcow/bamUtil/gcc-4.4.6/1.0.7
		bam clipOverlap --readName --in $OUTPUT/"$Lane".name.bam --out $OUTPUT/"$Lane".name.clip.bam
	fi
elif [[ "$Clip" -gt 0 ]]
then
	module load marcow/bamUtil/gcc-4.4.6/1.0.7
	bam clipOverlap --in $OUTPUT/"$Lane".bam --out $OUTPUT/"$Lane".clip.bam
	samtools index $OUTPUT/"$Lane".clip.bam
fi

echo `date`" - Finished alignment" >> "$LOGFILE"
