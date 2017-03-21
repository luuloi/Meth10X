#!/bin/bash -e

# load module 
export MODULEPATH=/share/ClusterShare/Modules/modulefiles/noarch:/share/ClusterShare/Modules/modulefiles/centos6.2_x86_64:/share/ClusterShare/Modules/modulefiles/contrib:$MODULEPATH 
source /etc/profile.d/modules.sh
# load module
module load phuluu/python/2.7.8
module load aarsta/bwa/0.7.9a
module load phuluu/bwa-meth/0.10
module load gi/samtools/1.2


if [ $# -lt 5 ]
then
  echo "Usage: `basename $0` {Forward_Read_path} {Reverse_Read_path} {Genome} {Output_path} {N_CORES}"
  exit 1
fi

Ncores=$5

# $1==raw_trimmed/PrEC/TKCC20140214_PrEC_P6_Test_trimmed/TKCC20140214_PrEC_P6_Test_02_trimmed_R1.fastq.gz 
SampleName=$(echo $1| cut -d/ -f2)
Lane=$(echo $1| cut -d/ -f3)
INPUT=$(dirname $1)
FW=$1
RV=$2
GENOME=$3
# aligned/PrEC/TKCC20140214_PrEC_P6_Test_trimmed
OUTPUT=$4

LOGFILE=$OUTPUT/"$Lane".alignment.log

echo "WGBS10X bwameth.align.sh" > "$LOGFILE"
echo `date`" - Started processing $1 on $HOSTNAME" >> "$LOGFILE"
echo "Bisulfite alignment" >> "$LOGFILE"

if [[ -e $INPUT/"$Lane".fastq.gz ]]
then
	echo "Single end alignment of ""$Lane" >> "$LOGFILE"
    Paired=0
elif [[ -e $INPUT/"$Lane"_R1.fastq.gz ]]
then
	echo "Paired end alignment of ""$Lane" >> "$LOGFILE"
    Paired=1
else
	echo "Error - ""$INPUT/$Lane"" files not found" >> "$LOGFILE"
	exit 1
fi

echo `date`" - Starting alignment" >> "$LOGFILE"
if [[ "$Paired" -gt 0 ]]
then
	bwameth.py --threads $Ncores --read-group @RG\\tID:"$Lane"\\tSM:"$SampleName" --reference "$GENOME" "$FW" "$RV" --prefix $OUTPUT/"$Lane".align >> "$LOGFILE" 2>&1
	samtools index $OUTPUT/"$Lane".align.bam 1>&2 >> "$LOGFILE"
else
	bwameth.py --threads $Ncores --read-group @RG\\tID:"$Lane"\\tSM:"$SampleName" --reference "$GENOME" "$FW" --prefix $OUTPUT/"$Lane".align >> "$LOGFILE" 2>&1
	samtools index $OUTPUT/"$Lane".align.bam 1>&2 >> "$LOGFILE"
fi

echo `date`" - Finished alignment" >> "$LOGFILE"

