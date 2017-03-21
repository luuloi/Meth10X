#!/bin/bash -e

# load module 
export MODULEPATH=/share/ClusterShare/Modules/modulefiles/noarch:/share/ClusterShare/Modules/modulefiles/centos6.2_x86_64:/share/ClusterShare/Modules/modulefiles/contrib:$MODULEPATH
source /etc/profile.d/modules.sh

# INPUT=Test_Prostate/raw/LNCaP/TKCC20140123_LNCaP_P73_Test/TKCC20140123_LNCaP_P73_Test_R1.fastq.sh
# cat Test_Prostate/raw/LNCaP/TKCC20140123_LNCaP_P73_Test/TKCC20140123_LNCaP_P73_Test_R1.fastq.sh
# rsync -avPS lpl913@r-dm.nci.org.au:/g/data3/yo4/Cancer-Epigenetics-Data/Bis-Seq_Level_1/Test//TKCC20140123_LNCaP_P73_Test/TKCC20140123_LNCaP_P73_Test_R1.fastq.gz /home/phuluu/data/WGBS10X_new/Test_Prostate/raw/LNCaP/TKCC20140123_LNCaP_P73_Test/
INPUT=$1
# cat Test_Prostate/raw/LNCaP/TKCC20140123_LNCaP_P73_Test/TKCC20140123_LNCaP_P73_Test_R1.fastq.sh| cut -d" " -f4
# /home/phuluu/data/WGBS10X_new/Test_Prostate/raw/LNCaP/TKCC20140123_LNCaP_P73_Test/
OUTPUTdir=$(cat $INPUT| cut -d" " -f4)
LOGFILE="$OUTPUTdir"/$(basename $INPUT)".download.log"

# echo $OUTPUTdir
# echo $LOGFILE

# host=$(cat Test_Prostate/raw/LNCaP/TKCC20140123_LNCaP_P73_Test/TKCC20140123_LNCaP_P73_Test_R1.fastq.sh| cut -d" " -f3| cut -d: -f1)
host=$(cat $INPUT| cut -d" " -f3| cut -d: -f1)
# url=$(cat Test_Prostate/raw/LNCaP/TKCC20140123_LNCaP_P73_Test/TKCC20140123_LNCaP_P73_Test_R1.fastq.sh| cut -d" " -f3| cut -d: -f2)
filepath=$(cat $INPUT| cut -d" " -f3| cut -d: -f2)
# ssh $host ls $url
file_exist=$(ssh $host "ls $filepath")

if [ ${#file_exist} -gt 1 ] ; then
	echo `date` >> $LOGFILE
	echo "File path exists. Downloading ..." >> $LOGFILE
	cat $INPUT >> $LOGFILE
	bash $INPUT 2>> $LOGFILE
	echo `date`" - Finished download fastq files" >> $LOGFILE
else
	echo "$INPUT do not exist. Please check again!" >> $LOGFILE
fi

