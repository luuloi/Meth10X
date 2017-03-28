#!bin/bash

# usage: bash CpGibias.and.compute.distribution.sh input output CpGislands CpGshores others GSIZE

# load module 
export MODULEPATH=/share/ClusterShare/Modules/modulefiles/noarch:/share/ClusterShare/Modules/modulefiles/centos6.2_x86_64:/share/ClusterShare/Modules/modulefiles/contrib:$MODULEPATH
source /etc/profile.d/modules.sh
module load gi/bedtools/2.22.0

# INPUT="/home/darloluu/tmp/Test_Prostate/called/LNCaP/LNCaP.MD_CpG.tsv.gz"
# chr	position	LNCaP.C		LNCaP.cov
# chr1	10468		0			0
# chr1	10470		0			0

INPUT=$1
# OUTPUT="/home/darloluu/tmp/Test_Prostate/bigTables/QC/distributions"
OUTPUT=$2
# sample="PrEC"
sample=$(basename $INPUT| cut -d. -f1)
# GENOME="/share/ClusterShare/biodata/contrib/phuluu/bwa_meth/annotations/hg19/hg19.fa"
GENOME=$3
# others="/share/ClusterShare/biodata/contrib/phuluu/bwa_meth/annotations/hg19/hg19.others.bed"
others=${GENOME/.fa/.others.bed}

mkdir -p $OUTPUT
LOGFILE="$OUTPUT/${sample}.compute.distribution.others.log"


echo `date`" - Smooth methylation ratio CpG and compute methylation distribution" > "$LOGFILE"
# others
cmd="""
bedtools intersect -a $others -b "$OUTPUT/${sample}.methratio.bed" -wa -wb| \
bedtools groupby -i - -g 1,2,3 -c 7 -o mean| awk '{ printf \"%.4f\n\", \$4}'| sort -T $OUTPUT| uniq -c| \
awk -v sample=$sample '{OFS=\"\t\"}{print sample,\$2,\$1}' > "$OUTPUT/${sample}.distribution.others.tsv"
""" 
echo $cmd >> "$LOGFILE"; eval $cmd 2>> "$LOGFILE"
echo `date`" - Finished processing $1" >> "$LOGFILE"



