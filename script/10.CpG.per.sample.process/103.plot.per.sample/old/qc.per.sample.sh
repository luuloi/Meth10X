#!bin/bash

# usage: bash qc.per.sample.sh input output

# load module 
export MODULEPATH=/share/ClusterShare/Modules/modulefiles/noarch:/share/ClusterShare/Modules/modulefiles/centos6.2_x86_64:/share/ClusterShare/Modules/modulefiles/contrib:$MODULEPATH 
export PATH=/home/phuluu/bin:$PATH
source /etc/profile.d/modules.sh


BASEDIR=$(dirname $0)
# INPUT="/home/darloluu/tmp/Test_Prostate/called/LNCaP/LNCaP.MD_CpG.tsv.gz"
# chr	position	LNCaP.C		LNCaP.cov
# chr1	10468		0			0
# chr1	10470		0			0
INPUT=$1
# OUTPUT="/home/darloluu/tmp/Test_Prostate/bigTable/QC/per-sample"
OUTPUT=$2
# sample="PrEC"
sample=$(basename $INPUT| cut -d. -f1)

mkdir -p $OUTPUT
LOGFILE="$OUTPUT/${sample}.CpG.coverage.log"

# example
# zcat Adultbrain_bis_2_CEGX/Adultbrain_bis_2_CEGX.MD_CpG.tsv.gz| awk 'NR>1{if($3>$4){exit}else{print $4}}'| sort -k1,1n| uniq -c| \
# awk '{arr[$2]=$1;sum+=$1}END{for(i in arr) print "a","\t",i,"\t",100*arr[i]/sum}'| sort -k2,2n > cov.tsv

echo " *** DNAmeth distribution per chromosome" > "$LOGFILE"
echo `date`" - Started processing $1 on $HOSTNAME" >> "$LOGFILE"
echo " - Compute coverage for each CpG" >> "$LOGFILE"

echo -e "Sample\tDepth\tFraction" > "$OUTPUT/${sample}.CpG.coverage.tsv"
cmd="""
zcat $INPUT|egrep \"chr[0-9XYM]\"| awk 'NR>1{if(\$3>\$4){exit}else{print \$4}}'| sort -n| uniq -c| awk '{OFS=\"\t\"}{arr[\$2]=\$1;sum+=\$1}END{for(i in arr){print \"$sample\",i,100*arr[i]/sum}}'| sort -k2,2n >> $OUTPUT/${sample}.CpG.coverage.tsv
"""
echo $cmd >> "$LOGFILE"; eval $cmd 2>> "$LOGFILE"

echo `date`" - Finished processing $1" >> $LOGFILE


### example
# INPUT=/home/phuluu/data/WGBS10X_new/Prostate_Brain/called/Adultbrain_bis_2_CEGX/Adultbrain_bis_2_CEGX.MD_CpG.tsv.gz 
# OUTPUT=/home/phuluu/data/WGBS10X_new/Prostate_Brain/bigTable/QC/per-sample
# sample=Adultbrain_bis_2_CEGX

# zcat /home/phuluu/data/WGBS10X_new/Prostate_Brain/called/Adultbrain_bis_2_CEGX/Adultbrain_bis_2_CEGX.MD_CpG.tsv.gz|egrep "chr[0-9XYM]"| \
# awk 'NR>1{if($3>$4){exit}else{print $4}}'| sort -k1,1n| uniq -c| \
# awk '{OFS="\t"}{arr[$2]=$1;sum+=$1}END{for(i in arr){print "Adultbrain_bis_2_CEGX",i,100*arr[i]/sum}}'| \
# sort -k2,2n >> /home/phuluu/data/WGBS10X_new/Prostate_Brain/bigTable/QC/per-sample/Adultbrain_bis_2_CEGX.CpG.coverage.tsv
