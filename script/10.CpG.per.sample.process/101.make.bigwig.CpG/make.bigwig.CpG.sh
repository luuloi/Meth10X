#!bin/bash

# usage: bash make.bigwig.CpG.sh input output GSIZE minCov

# load module 
export MODULEPATH=/share/ClusterShare/Modules/modulefiles/noarch:/share/ClusterShare/Modules/modulefiles/centos6.2_x86_64:/share/ClusterShare/Modules/modulefiles/contrib:$MODULEPATH 
export PATH=/home/phuluu/bin:$PATH
source /etc/profile.d/modules.sh
module load gi/bedtools/2.22.0
BEDGRAPH=/home/darloluu/bin/ucsc/bedGraphToBigWig

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
LOGFILE="$OUTPUT/${sample}.make.bigwig.CpG.log"

echo " *** Make CpG bigwig file " > "$LOGFILE"
echo `date`" - Started processing $1 on $HOSTNAME" >> "$LOGFILE"
echo " - Converted bedGraph to coverage of CpG bw" >> "$LOGFILE"

# coverage single CpG sites
cmd="""
zcat $INPUT| egrep \"chr[0-9XYM]\"| awk -v minCov=$minCov '{OFS=\"\t\"}NR>1{ if(\$4>=minCov) print \$1,\$2,\$2,\$4}' > "$OUTPUT/${sample}.bedGraph" 
""" 
echo $cmd >> "$LOGFILE"; eval $cmd 2>> "$LOGFILE"

cmd="""
$BEDGRAPH "$OUTPUT/${sample}.bedGraph" $GSIZE "$OUTPUT/${sample}.cov.bw"
"""
echo $cmd >> "$LOGFILE"; eval $cmd 2>> "$LOGFILE"

# methylation ratio single CpG sites
echo `date`" - Converted bedGraph to methylation ratio CpG bw" >> "$LOGFILE"
cmd="""
zcat $INPUT| egrep \"chr[0-9XYM]\"| awk -v minCov=$minCov '{OFS=\"\t\"}NR>1{if(\$4>=minCov){print \$1,\$2,\$2,\$3/\$4}else{print \$1,\$2,\$2,-1}}' > "$OUTPUT/${sample}.bedGraph"
"""
echo $cmd >> "$LOGFILE"; eval $cmd 2>> "$LOGFILE"
cmd="""
$BEDGRAPH "$OUTPUT/${sample}.bedGraph" $GSIZE "$OUTPUT/${sample}.bw"
"""
echo $cmd >> "$LOGFILE"; eval $cmd 2>> "$LOGFILE"
echo `date`" - Smooth methylation ratio CpG and create bw" >> "$LOGFILE"

# 100bp
echo " - 100bp"  >> "$LOGFILE"
cmd="""
bedtools intersect -a <(bedtools makewindows -g $GSIZE -w 100) -b "$OUTPUT/${sample}.bedGraph" -loj|
awk '{OFS=\"\t\"}{if(\$7==\".\"){\$7=-1}; print \$1,\$2,\$3,\$7}'|
bedtools groupby -g 1,2,3 -c 4 -o collapse|
awk '{OFS=\"\t\"}{s=0; c=0; split(\$4,a,\",\"); for(i=1;i<=length(a);i++){if(a[i]>=0){s=s+a[i];c=c+1}}; if(c>0){print \$1,\$2,\$3,s/c}else{print \$1,\$2,\$3,-1}}' > "$OUTPUT/smoothed/${sample}.smoothed.bedGraph"
"""
echo $cmd >> "$LOGFILE"; eval $cmd 2>> "$LOGFILE"
cmd="""
$BEDGRAPH "$OUTPUT/smoothed/${sample}.smoothed.bedGraph" $GSIZE "$OUTPUT/smoothed/${sample}.100bp.bw"
"""
echo $cmd >> "$LOGFILE"; eval $cmd 2>> "$LOGFILE"

# 1kb
echo " - 1kb"  >> "$LOGFILE"
cmd="""
bedtools intersect -a <(bedtools makewindows -g $GSIZE -w 1000) -b "$OUTPUT/${sample}.bedGraph" -loj|
awk '{OFS=\"\t\"}{if(\$7==\".\"){\$7=-1}; print \$1,\$2,\$3,\$7}'|
bedtools groupby -g 1,2,3 -c 4 -o collapse|
awk '{OFS=\"\t\"}{s=0; c=0; split(\$4,a,\",\"); for(i=1;i<=length(a);i++){if(a[i]>=0){s=s+a[i];c=c+1}}; if(c>0){print \$1,\$2,\$3,s/c}else{print \$1,\$2,\$3,-1}}' > "$OUTPUT/smoothed/${sample}.smoothed.bedGraph"
"""
echo $cmd >> "$LOGFILE"; eval $cmd 2>> "$LOGFILE"
cmd="""
$BEDGRAPH "$OUTPUT/smoothed/${sample}.smoothed.bedGraph" $GSIZE "$OUTPUT/smoothed/${sample}.1kb.bw"
"""
echo $cmd >> "$LOGFILE"; eval $cmd 2>> "$LOGFILE"

# 10kb
echo " - 10kb"  >> "$LOGFILE"
cmd="""
bedtools intersect -a <(bedtools makewindows -g $GSIZE -w 10000) -b "$OUTPUT/${sample}.bedGraph" -loj|
awk '{OFS=\"\t\"}{if(\$7==\".\"){\$7=-1}; print \$1,\$2,\$3,\$7}'|
bedtools groupby -g 1,2,3 -c 4 -o collapse|
awk '{OFS=\"\t\"}{s=0; c=0; split(\$4,a,\",\"); for(i=1;i<=length(a);i++){if(a[i]>=0){s=s+a[i];c=c+1}}; if(c>0){print \$1,\$2,\$3,s/c}else{print \$1,\$2,\$3,-1}}' > "$OUTPUT/smoothed/${sample}.smoothed.bedGraph"
"""
echo $cmd >> "$LOGFILE"; eval $cmd 2>> "$LOGFILE"
cmd="""
$BEDGRAPH "$OUTPUT/smoothed/${sample}.smoothed.bedGraph" $GSIZE "$OUTPUT/smoothed/${sample}.10kb.bw"
"""
echo $cmd >> "$LOGFILE"; eval $cmd 2>> "$LOGFILE"

# 100kb
echo " - 100kb"  >> "$LOGFILE"
cmd="""
bedtools intersect -a <(bedtools makewindows -g $GSIZE -w 100000) -b "$OUTPUT/${sample}.bedGraph" -loj|
awk '{OFS=\"\t\"}{if(\$7==\".\"){\$7=-1}; print \$1,\$2,\$3,\$7}'|
bedtools groupby -g 1,2,3 -c 4 -o collapse|
awk '{OFS=\"\t\"}{s=0; c=0; split(\$4,a,\",\"); for(i=1;i<=length(a);i++){if(a[i]>=0){s=s+a[i];c=c+1}}; if(c>0){print \$1,\$2,\$3,s/c}else{print \$1,\$2,\$3,-1}}' > "$OUTPUT/smoothed/${sample}.smoothed.bedGraph"
"""
echo $cmd >> "$LOGFILE"; eval $cmd 2>> "$LOGFILE"
cmd="""
$BEDGRAPH "$OUTPUT/smoothed/${sample}.smoothed.bedGraph" $GSIZE "$OUTPUT/smoothed/${sample}.100kb.bw"  
"""
echo $cmd >> "$LOGFILE"; eval $cmd 2>> "$LOGFILE"

# clean
echo " - clean up"  >> "$LOGFILE"
cmd=""" 
rm "$OUTPUT/${sample}.bedGraph" "$OUTPUT/smoothed/${sample}.smoothed.bedGraph"
"""
echo $cmd >> "$LOGFILE"; eval $cmd 2>> "$LOGFILE"
echo `date`" - Finished processing $1" >> "$LOGFILE"


