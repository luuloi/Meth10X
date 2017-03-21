#!bin/bash

# usage: bash make.bigwig.CpG.sh input output GSIZE minCov

# load module 
export MODULEPATH=/share/ClusterShare/Modules/modulefiles/noarch:/share/ClusterShare/Modules/modulefiles/centos6.2_x86_64:/share/ClusterShare/Modules/modulefiles/contrib:$MODULEPATH
source /etc/profile.d/modules.sh
module load gi/bedtools/2.22.0
# bedGraphToBigWig
module load phuluu/UCSC/v4

# INPUT="/home/darloluu/tmp/Test_Prostate/bigTables/bw/LNCaP.bw"
INPUT=$1
# OUTPUT="/home/darloluu/tmp/Test_Prostate/bigTables/bw/smoothed"
OUTPUT=$2
# sample="LNCaP"
sample=$(basename $INPUT| cut -d. -f1)
# GSIZE="/home/darloluu/methods/darlo/annotations/hg19/hg19.chrom.sizes.short"
GSIZE=${3/.fa/.chrom.sizes.short}
# minCov=3
minCov=$4


LOGFILE="$OUTPUT/${sample}.make.bigwig.CpG.meth.ratio.100kb.log"

echo `date`" - Smooth methylation ratio CpG and create bw" > "$LOGFILE"

# 100kb
echo " - 100kb"  >> "$LOGFILE"
cmd="""
bedtools intersect -a <(bedtools makewindows -g $GSIZE -w 100000) -b "${INPUT/.cov.bw/.meth.ratio.bedGraph}" -loj|
awk '{OFS=\"\t\"}{if(\$7==\".\"){\$7=-1}; print \$1,\$2,\$3,\$7}'|
bedtools groupby -g 1,2,3 -c 4 -o collapse|
awk '{OFS=\"\t\"}{s=0; c=0; split(\$4,a,\",\"); for(i=1;i<=length(a);i++){if(a[i]>=0){s=s+a[i];c=c+1}}; if(c>0){print \$1,\$2,\$3,s/c}else{print \$1,\$2,\$3,-1}}' > "$OUTPUT/${sample}.smoothed.100kb.bedGraph"
"""
echo $cmd >> "$LOGFILE"; eval $cmd 2>> "$LOGFILE"
cmd=""" bedGraphToBigWig "$OUTPUT/${sample}.smoothed.100kb.bedGraph" $GSIZE "$OUTPUT/${sample}.100kb.bw" """
echo $cmd >> "$LOGFILE"; eval $cmd 2>> "$LOGFILE"

# clean
echo " - clean up"  >> "$LOGFILE"
cmd=""" 
rm "$OUTPUT/${sample}.smoothed.100kb.bedGraph"
"""
echo $cmd >> "$LOGFILE"; eval $cmd 2>> "$LOGFILE"

echo `date`" - Finished processing $1" >> "$LOGFILE"
