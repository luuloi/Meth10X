#!/bin/bash -e

# load module 
export MODULEPATH=/share/ClusterShare/Modules/modulefiles/noarch:/share/ClusterShare/Modules/modulefiles/centos6.2_x86_64:/share/ClusterShare/Modules/modulefiles/contrib:$MODULEPATH
source /etc/profile.d/modules.sh
module load gi/fastqc/0.11.5 

# INPUT=raw/LNCaP/TKCC20140123_LNCaP_P73_Test/TKCC20140123_LNCaP_P73_Test_R2.fastq.gz
# OUTPUT=raw/LNCaP/TKCC20140123_LNCaP_P73_Test/TKCC20140123_LNCaP_P73_Test_R2_fastqc.zip
INPUT=$1
OUTPUT=$2
LOGFILE="$OUTPUT/$(basename $INPUT).fastqc.log"

if [ -e $INPUT ] ; then
	echo `date` >> $LOGFILE
	echo "INPUT=$INPUT" >> $LOGFILE
	echo "OUTPUT=$OUTPUT" >> $LOGFILE
	echo zcat $INPUT| head -n 4 >> $LOGFILE
	zcat $INPUT| head -n 4 2>> $LOGFILE 
	echo fastqc -t 24 -o $OUTPUT $INPUT >> $LOGFILE
	fastqc -t 24 -o $OUTPUT $INPUT 2>> $LOGFILE
else
	echo "$INPUT do not exist. Please check again!" >> $LOGFILE
fi
