#!bin/bash

# usage: bash make.bigwig.CpG.sh input output GSIZE minCov

# load module 
export MODULEPATH=/share/ClusterShare/Modules/modulefiles/noarch:/share/ClusterShare/Modules/modulefiles/centos6.2_x86_64:/share/ClusterShare/Modules/modulefiles/contrib:$MODULEPATH 
export PATH=/home/phuluu/bin:$PATH
source /etc/profile.d/modules.sh
module load gi/bedtools/2.22.0
BEDGRAPH=/home/darloluu/bin/ucsc/bedGraphToBigWig

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


LOGFILE="$OUTPUT/${sample}.make.bigwig.CpG.meth.ratio.1kb.log"

echo `date`" - Smooth methylation ratio CpG and create bw" > "$LOGFILE"

# 1kb
echo " - 1kb"  >> "$LOGFILE"
cmd="""
bedtools intersect -a <(bedtools makewindows -g $GSIZE -w 1000) -b "${INPUT/.cov.bw/.meth.ratio.bedGraph}" -loj|
awk '{OFS=\"\t\"}{if(\$7==\".\"){\$7=-1}; print \$1,\$2,\$3,\$7}'|
bedtools groupby -g 1,2,3 -c 4 -o collapse|
awk '{OFS=\"\t\"}{s=0; c=0; split(\$4,a,\",\"); for(i=1;i<=length(a);i++){if(a[i]>=0){s=s+a[i];c=c+1}}; if(c>0){print \$1,\$2,\$3,s/c}else{print \$1,\$2,\$3,-1}}' > "$OUTPUT/${sample}.smoothed.1kb.bedGraph"
"""
echo $cmd >> "$LOGFILE"; eval $cmd 2>> "$LOGFILE"
cmd="""
$BEDGRAPH "$OUTPUT/${sample}.smoothed.1kb.bedGraph" $GSIZE "$OUTPUT/${sample}.1kb.bw"
"""
echo $cmd >> "$LOGFILE"; eval $cmd 2>> "$LOGFILE"

# clean
echo " - clean up"  >> "$LOGFILE"
cmd=""" 
rm "$OUTPUT/${sample}.smoothed.1kb.bedGraph"
"""
echo $cmd >> "$LOGFILE"; eval $cmd 2>> "$LOGFILE"


echo `date`" - Finished processing $1" >> "$LOGFILE"