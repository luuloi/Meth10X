#!bin/bash
# load module 
export MODULEPATH=/share/ClusterShare/Modules/modulefiles/noarch:/share/ClusterShare/Modules/modulefiles/centos6.2_x86_64:/share/ClusterShare/Modules/modulefiles/contrib:$MODULEPATH
source /etc/profile.d/modules.sh
module load phuluu/R/3.1.2

BASEDIR=$(dirname $0)
# INPUT="bigTable/bigTable.tsv.gz"
input=$1
# OUTPUT="bigTable/QC/distributions/"
output=$2

LOGFILE="$output/DNA.meth.distribution.plot.each.CpG.log"

echo "DNA.meth.distribution.plot.each.CpG.sh" > "$LOGFILE"
echo `date`" - Started processing $1 on $HOSTNAME" >> "$LOGFILE"
Rscript "$BASEDIR/DNA.meth.distribution.plot.each.CpG.r" "$output" 2>> "$LOGFILE"
echo `date`" - Finished the processing" >> "$LOGFILE"
