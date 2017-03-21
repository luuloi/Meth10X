#!bin/bash
# load module 
export MODULEPATH=/share/ClusterShare/Modules/modulefiles/noarch:/share/ClusterShare/Modules/modulefiles/centos6.2_x86_64:/share/ClusterShare/Modules/modulefiles/contrib:$MODULEPATH 
export PATH=/home/phuluu/bin:$PATH
source /etc/profile.d/modules.sh
module load phuluu/R/3.1.2

BASEDIR=$(dirname $0)
# INPUT="bigTable/QC"
input=$1
# OUTPUT="/home/darloluu/tmp/Test_Prostate/bigTables/QC"
output=$2

LOGFILE="$output/merge.CpG.bias.log"

echo "merge.CpG.bias.sh" > "$LOGFILE"
echo `date`" - Started processing $1 on $HOSTNAME" >> "$LOGFILE"
Rscript "$BASEDIR/merge.CpG.bias.r" "$input" "$output" 2>> "$LOGFILE"
echo `date`" - Finished the processing" >> "$LOGFILE"

