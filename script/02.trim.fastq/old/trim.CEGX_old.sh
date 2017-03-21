#!/bin/bash -e

# load module 
export MODULEPATH=/share/ClusterShare/Modules/modulefiles/noarch:/share/ClusterShare/Modules/modulefiles/centos6.2_x86_64:/share/ClusterShare/Modules/modulefiles/contrib:$MODULEPATH 
export PATH=/home/phuluu/bin:$PATH
source /etc/profile.d/modules.sh
# load cutadapt (in python so load python)
module load phuluu/python/2.7.8
module load gi/java/jdk1.8.0_25
module load gi/fastqc/0.11.3

# $1=raw/LNCaP/TKCC20140123_LNCaP_P73_Test/TKCC20140123_LNCaP_P73_Test_R1.fastq.gz
# $2=raw_trimmed/LNCaP/TKCC20140123_LNCaP_P73_Test_trimmed/TKCC20140123_LNCaP_P73_Test_trimmed_R1.fastq
# $3=raw/LNCaP/TKCC20140123_LNCaP_P73_Test/TKCC20140123_LNCaP_P73_Test_R2.fastq.gz
# $4=raw_trimmed/LNCaP/TKCC20140123_LNCaP_P73_Test_trimmed/TKCC20140123_LNCaP_P73_Test_trimmed_R2.fastq
# $5=raw_trimmed/LNCaP/TKCC20140123_LNCaP_P73_Test_trimmed/
LOGFILE="${2/_R1.fastq.gz/}.trim.log"
echo `date`"- Start trim the GEGX fastq file" > $LOGFILE
echo "Trimming" >> $LOGFILE
cutadapt -m 15 -u -7 -U 7 -o ${2/.gz/} -p ${4/.gz/} $1 $3 1>&2 >> $LOGFILE
echo "Compress these fastq files" >> $LOGFILE
gzip ${2/.gz/}
gzip ${4/.gz/}
echo "QC after trimmed" >> $LOGFILE
echo "ls $5/*.fastq.gz| xargs -P 2 fastqc -o $5" >> $LOGFILE
ls $5/*.fastq.gz| xargs -P 2 fastqc -o $5 &2>> $LOGFILE
echo `date`"- Finished the trimming" >> $LOGFILE

