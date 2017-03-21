#!/bin/bash -e

# load module 
export MODULEPATH=/share/ClusterShare/Modules/modulefiles/noarch:/share/ClusterShare/Modules/modulefiles/centos6.2_x86_64:/share/ClusterShare/Modules/modulefiles/contrib:$MODULEPATH 
source /etc/profile.d/modules.sh
module load gi/samtools/1.2
module load gi/bedtools/2.22.0
module load phuluu/R/3.1.2
# bedGraphToBigWig
module load phuluu/UCSC/v4


# $1=merged/PrEC/PrEC.bam
INPUT=${1/.bam/}
sample=$(basename $INPUT| cut -d. -f1)
# $2=merged/PrEC
OUTPUT=$2

LOGFILE="${OUTPUT}/${sample}.coverage.bedGraph.log"
echo `date`" *** Created coverage bedGraph" > $LOGFILE
echo """ samtools view -F 1024 -q40 -b ${INPUT}.clip.bam| bedtools bamtobed -splitD | awk '{if (\$3>\$2) print $0}' | bedtools genomecov -i - -bga -g ${INPUT}.chrom.sizes > ${INPUT}.coverage.bedGraph """ >> $LOGFILE
samtools view -F 1024 -q40 -b "${INPUT}.clip.bam"| bedtools bamtobed -splitD | awk '{if ($3>$2) print $0}' | bedtools genomecov -i - -bga -g "${INPUT}.chrom.sizes" > "${INPUT}.coverage.bedGraph" 2>> $LOGFILE
echo `date`" - Finished coverage bedGraph" >> $LOGFILE


LOGFILE="${OUTPUT}/${sample}.coverage.bw.log"
echo `date`" *** Converted bedGraph to bigwig" > $LOGFILE
echo """ bedGraphToBigWig ${INPUT}.coverage.bedGraph ${INPUT}.chrom.sizes ${INPUT}.coverage.bw """ >> $LOGFILE
bedGraphToBigWig "${INPUT}.coverage.bedGraph" "${INPUT}.chrom.sizes" "${INPUT}.coverage.bw" 2>> $LOGFILE
echo `date`" - Finished convert bedGraph to bigwig" >> $LOGFILE


LOGFILE="${OUTPUT}/${sample}.calculate.depth.log"
echo `date`" *** Calculated depth statistics" > $LOGFILE
echo "R --vanilla -e 'f=\'${INPUT}\'; options(scipen=100); library(rtracklayer); x <- import(paste0(f, '.coverage.bedGraph')); w <- as.numeric(width(x)); s <- as.numeric(S4Vectors::mcols(x)[['score']]); writeLines(paste(c('depth:', 'mean_coverage:'), c(sum(w*s), weighted.mean(s, w))), paste0(f, '.depth'))" >> $LOGFILE
R --vanilla -e "f=\"${INPUT}\"; options(scipen=100); library(rtracklayer); x <- import(paste0(f, '.coverage.bedGraph')); w <- as.numeric(width(x)); s <- as.numeric(S4Vectors::mcols(x)[['score']]); writeLines(paste(c('depth:', 'mean_coverage:'), c(sum(w*s), weighted.mean(s, w))), paste0(f, '.depth'))" 2>> $LOGFILE
echo `date`" - Finished calculate depth" >> $LOGFILE
### example
# head 5060_bis_6_CEGX/5060_bis_6_CEGX.coverage.bedGraph
# chr1	0	10002	0
# chr1	10002	10057	1
# chr1	10057	10140	2
# chr1	10140	10216	1
# INPUT="merged/5060_bis_6_CEGX/5060_bis_6_CEGX"
# OUTPUT="merged/5060_bis_6_CEGX/"
# sample="5060_bis_6_CEGX"
# cat 5060_bis_6_CEGX/5060_bis_6_CEGX.coverage.bedGraph| awk '{print $4, ($3-$2)}'| sort -k1,1n| awk '{arr[$1]+=$2;sum+=$2}END{for(i in arr){print "5060_bis_6_CEGX","\t",i,"\t",100*arr[i]/sum}}'| sort -k1,1n > whole.genome.coverage.tsv
LOGFILE="${OUTPUT}/${sample}.coverage.distribution.whole.genome.log"
echo `date`" *** Calculated coverage distribution for each site in genome" > $LOGFILE
echo -e "Sample\tDepth\tFraction" > "$OUTPUT/QC/genome_coverage.tsv"
cmd="""
awk '{OFS=\"\t\"}{print \$4, \$3-\$2}' ${INPUT}.coverage.bedGraph| sort -k1,1n| awk '{arr[\$1]+=\$2;sum+=\$2}END{for(i in arr){print \"$sample\",\"\t\",i,\"\t\",100*arr[i]/sum}}'| sort -k2,2n >> $OUTPUT/QC/genome_coverage.tsv
"""
echo $cmd >> "$LOGFILE"; eval $cmd 2>> "$LOGFILE"

# clean up
echo rm "${INPUT}.coverage.bedGraph" >> $LOGFILE
rm "${INPUT}.coverage.bedGraph" 2>> $LOGFILE
echo `date`" - Finished calculate depth" >> $LOGFILE

# Note: bw and depth files are generated from clipped and deduplicated bam with mapq score >=40

