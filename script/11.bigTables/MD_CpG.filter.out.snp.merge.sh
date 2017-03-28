#!bin/bash -e
# usage: bash methyldackel.sh input output reference


# load module 
export MODULEPATH=/share/ClusterShare/Modules/modulefiles/noarch:/share/ClusterShare/Modules/modulefiles/centos6.2_x86_64:/share/ClusterShare/Modules/modulefiles/contrib:$MODULEPATH 
source /etc/profile.d/modules.sh
module load phuluu/pigz/2.3.4

# get paramaters
# $1=/home/phuluu/data/WGBS10X_new/Test_Prostate/bigTable/merge/*MD_CpG.merge
input=$1
# $2=bigTables
output=$2
LOGFILE="$output/MD_CpG.filter.out.snp.merge.log"


# 'MD_CpG.merge'
# paste <(head /home/phuluu/Projects/WGBS10X_new/V02/annotations/hg19/hg19.CpG.bed| cut -f1,3,6) \
# <(zcat /home/phuluu/data/WGBS10X_new/Test_Prostate/called/PrEC/PrEC.MD_CpG.tsv.gz| cut -f5,6|head) \
# <(zcat /home/phuluu/data/WGBS10X_new/Test_Prostate/called/LNCaP/LNCaP.MD_CpG.tsv.gz| cut -f5,6| head)
echo `date`" *** Merge MD_CpG.filter.out.snp.merge samples into bigTable" > $LOGFILE

echo "Sort and eliminate sample duplication" >> $LOGFILE
cmd="input_unique=\$(echo $input| awk '{for(i=1;i<=NF;i++){if(\$i ~ /MD_CpG.filter.out.snp.merge/) print \$i}}'| sort -u)"
echo $cmd >> "$LOGFILE"; eval $cmd 2>> "$LOGFILE"; echo -e `date`" Finished sort\n" >> $LOGFILE

echo "Merge now ..." >> $LOGFILE
cmd="paste <(zcat \$(cat -s $input_unique| awk 'NR==1{print \$0; exit}')|cut -f1,2)"
for i in `cat -s $input_unique`; do 
cmd="${cmd} <(zcat $i|cut -f3,4)"; 
done

cmd="$cmd > $output/bigTable.filtered.snp.tsv"
echo $cmd >> "$LOGFILE"; eval $cmd 2>> "$LOGFILE"; echo -e `date`" Finished merge\n" >> $LOGFILE

cmd="pigz -f $output/bigTable.filtered.snp.tsv"
echo $cmd >> "$LOGFILE"; eval $cmd 2>> "$LOGFILE"; echo -e `date`" Finished zip\n" >> $LOGFILE

echo `date`" Finished merge MD_CpG.filtered.snp samples into bigTable" >> $LOGFILE
