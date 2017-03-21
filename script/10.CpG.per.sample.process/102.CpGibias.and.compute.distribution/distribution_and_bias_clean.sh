#!bin/bash

# usage: bash CpGibias.and.compute.distribution.sh input output CpGislands CpGshores others GSIZE

# load module 
export MODULEPATH=/share/ClusterShare/Modules/modulefiles/noarch:/share/ClusterShare/Modules/modulefiles/centos6.2_x86_64:/share/ClusterShare/Modules/modulefiles/contrib:$MODULEPATH 
export PATH=/home/phuluu/bin:$PATH
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

LOGFILE="$OUTPUT/${sample}.distribution.and.bias.clean.log"

echo " *** Cleaning CpG island bias and distribution intermediate data" > "$LOGFILE"
echo `date`" - Started processing $1 on $HOSTNAME" >> "$LOGFILE"
# clean
cmd="""
rm "$OUTPUT/${sample}.cov.bed";
rm "$OUTPUT/${sample}.methratio.bed";
""" 
echo $cmd >> "$LOGFILE"; eval $cmd 2>> "$LOGFILE"
echo $cmd > "$OUTPUT/${sample}.clean"
echo `date`" - Finished processing $1" >> "$LOGFILE"
