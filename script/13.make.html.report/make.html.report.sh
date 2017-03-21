#!bin/bash
# load module 
export MODULEPATH=/share/ClusterShare/Modules/modulefiles/noarch:/share/ClusterShare/Modules/modulefiles/centos6.2_x86_64:/share/ClusterShare/Modules/modulefiles/contrib:$MODULEPATH
source /etc/profile.d/modules.sh
module load phuluu/R/3.1.2

BASEDIR=$(dirname $0)
# INPUT="/home/darloluu/tmp/Test_Prostate/bigTable/bigTable.tsv.gz"
input=$(dirname $1)
# OUTPUT="/home/darloluu/tmp/Test_Prostate/bigTable/QC"
output=$2

LOGFILE="$output/make.html.report.log"

echo "make.html.report.sh" > "$LOGFILE"
echo `date`" - Started processing $1 on $HOSTNAME" >> "$LOGFILE"
echo cp $BASEDIR/QC_Report.* "$input" >> "$LOGFILE"
cp -f $BASEDIR/QC_Report.* "$input" 2>> "$LOGFILE"
cd $input
echo R -e "knitr::knit2html('QC_Report.Rmd', stylesheet='QC_Report.css')" >> "$LOGFILE"
R -e "knitr::knit2html('QC_Report.Rmd', stylesheet='QC_Report.css')" 2>> "$LOGFILE"
echo `date`" - Finished the processing" >> "$LOGFILE"

