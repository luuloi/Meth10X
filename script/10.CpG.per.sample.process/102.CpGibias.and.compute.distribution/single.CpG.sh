#!bin/bash

# usage: bash CpGibias.and.compute.distribution.sh input output CpGislands CpGshores others GSIZE

# load module 
export MODULEPATH=/share/ClusterShare/Modules/modulefiles/noarch:/share/ClusterShare/Modules/modulefiles/centos6.2_x86_64:/share/ClusterShare/Modules/modulefiles/contrib:$MODULEPATH
source /etc/profile.d/modules.sh

# INPUT="/home/darloluu/tmp/Test_Prostate/called/LNCaP/LNCaP.MD_CpG.tsv.gz"
# chr	position	LNCaP.C		LNCaP.cov
# chr1	10468		0			0
# chr1	10470		0			0

INPUT=$1
# OUTPUT="/home/darloluu/tmp/Test_Prostate/bigTables/QC/distributions"
OUTPUT=$2
# sample="PrEC"
sample=$(basename $INPUT| cut -d. -f1)

mkdir -p $OUTPUT
LOGFILE="$OUTPUT/${sample}.compute.distribution.single.CpG.log"


echo `date`" - Smooth methylation ratio CpG and compute methylation distribution" > "$LOGFILE"
# single CpG
cmd="""
cut -f4 "$OUTPUT/${sample}.methratio.bed"| sort| uniq -c| awk -v sample=$sample '{OFS=\"\t\"}{print sample,\$2,\$1}' > "$OUTPUT/${sample}.distribution.Single_CpGs.tsv"
""" 
echo $cmd >> "$LOGFILE"; eval $cmd 2>> "$LOGFILE"
echo `date`" - Finished processing $1" >> "$LOGFILE"
