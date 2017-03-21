#!bin/bash

# usage: bash make.bigwig.CpG.sh input output GSIZE minCov

# load module 
export MODULEPATH=/share/ClusterShare/Modules/modulefiles/noarch:/share/ClusterShare/Modules/modulefiles/centos6.2_x86_64:/share/ClusterShare/Modules/modulefiles/contrib:$MODULEPATH
source /etc/profile.d/modules.sh
# bedGraphToBigWig
module load phuluu/UCSC/v4

# INPUT="/home/darloluu/tmp/Test_Prostate/called/LNCaP/LNCaP.MD_CpG.tsv.gz"
# chr	position	LNCaP.C		LNCaP.cov
# chr1	10469		0		0
# chr1	10471		0		0

INPUT=$1
# OUTPUT="/home/darloluu/tmp/Test_Prostate/bigTables/bw"
OUTPUT=$2
# sample="LNCaP"
sample=$(basename $INPUT| cut -d. -f1)
# GSIZE="/home/darloluu/methods/darlo/annotations/hg19/hg19.chrom.sizes.short"
GSIZE=${3/.fa/.chrom.sizes.short}
# minCov=3
minCov=$4

mkdir -p "$OUTPUT/smoothed"
LOGFILE="$OUTPUT/${sample}.make.bigwig.CpG.coverage.log"

echo " *** Make CpG bigwig file " > "$LOGFILE"
echo `date`" - Started processing $1 on $HOSTNAME" >> "$LOGFILE"
echo " - Converted bedGraph to coverage of CpG bw" >> "$LOGFILE"

# coverage single CpG sites
cmd="""
zcat $INPUT| egrep \"chr[0-9XYM]\"| awk -v minCov=$minCov '{OFS=\"\t\"}NR>1{ if(\$4>=minCov) print \$1,\$2,\$2,\$4}' > "$OUTPUT/${sample}.cov.bedGraph" 
""" 
echo $cmd >> "$LOGFILE"; eval $cmd 2>> "$LOGFILE"

cmd=""" bedGraphToBigWig "$OUTPUT/${sample}.cov.bedGraph" $GSIZE "$OUTPUT/${sample}.cov.bw" """
echo $cmd >> "$LOGFILE"; eval $cmd 2>> "$LOGFILE"

# clean
echo " - clean up"  >> "$LOGFILE"
cmd=""" 
rm "$OUTPUT/${sample}.cov.bedGraph"
"""
echo $cmd >> "$LOGFILE"; eval $cmd 2>> "$LOGFILE"
echo `date`" - Finished processing $1" >> "$LOGFILE"
