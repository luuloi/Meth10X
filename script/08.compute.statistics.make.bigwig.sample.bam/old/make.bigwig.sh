#!/bin/bash -e

# load module 
export MODULEPATH=/share/ClusterShare/Modules/modulefiles/noarch:/share/ClusterShare/Modules/modulefiles/centos6.2_x86_64:/share/ClusterShare/Modules/modulefiles/contrib:$MODULEPATH 
export PATH=/home/phuluu/bin:$PATH
source /etc/profile.d/modules.sh

BEDGRAPH=/home/darloluu/bin/ucsc/bedGraphToBigWig
LOGFILE=${1/.bam/.make.bigwig.log}

echo "make.bigwig.sh" > $LOGFILE
echo `date`" - Started processing $1 on $HOSTNAME" >> $LOGFILE

echo "*** Count MAPQ score" >> $LOGFILE
echo """ samtools view $OUTPUT/${sample}.bam| cut -f5 | sort -n | uniq -c > $OUTPUT/${sample}.mapq """ >> $LOGFILE
samtools view "$OUTPUT/${sample}.bam"| cut -f5 | sort -n | uniq -c > "$OUTPUT/${sample}.mapq" 2>> $LOGFILE
echo `date`" - Finished count MAPQ bam" >> $LOGFILE

echo `date`" - Clipping bam" >> $LOGFILE
echo bam clipOverlap --in $1 --poolSize 100000000 --out ${1/.bam/.clip.bam} >> $LOGFILE
bam clipOverlap --in $1 --poolSize 100000000 --out ${1/.bam/.clip.bam}
echo `date`" - Finished clipping bam" >> $LOGFILE


echo `date`" - Extracted chrom sizes from bam" >> $LOGFILE
echo """ samtools view -H $1 | grep ^@SQ | tr "\t" ":" | awk -F: '{print $3"\t"$5}' > $2/chrom.sizes """ >> $LOGFILE
samtools view -H $1 | grep ^@SQ | tr "\t" ":" | awk -F: '{print $3"\t"$5}' > "$2/chrom.sizes"

echo `date`" - Created coverage bedGraph" >> $LOGFILE
echo """ samtools view -q40 -b ${1/.bam/.clip.bam}| bedtools bamtobed -splitD | awk '{if ($3>$2) print $0}' | bedtools genomecov -i - -bga -g $2/chrom.sizes > ${1}.coverage.bedGraph """ >> $LOGFILE
samtools view -q40 -b ${1/.bam/.clip.bam}| bedtools bamtobed -splitD | awk '{if ($3>$2) print $0}' | bedtools genomecov -i - -bga -g "$2/chrom.sizes" > ${1}.coverage.bedGraph

echo `date`" - Converted bedGraph to bw" >> $LOGFILE
echo $BEDGRAPH ${1}.coverage.bedGraph "$2/chrom.sizes" ${1/.bam/.coverage.bw} >> $LOGFILE
$BEDGRAPH ${1}.coverage.bedGraph "$2/chrom.sizes" ${1/.bam/.coverage.bw}

# calculate coverage/depth
module load phuluu/R/3.1.2
echo `date`" - Calculated depth statistics" >> $LOGFILE
echo "R --vanilla -e 'f=\'$1\'; options(scipen=100); library(rtracklayer); x <- import(paste0(f, '.coverage.bedGraph')); w <- as.numeric(width(x)); s <- as.numeric(S4Vectors::mcols(x)[['score']]); writeLines(paste(c('depth:', 'mean_coverage:'), c(sum(w*s), weighted.mean(s, w))), paste0(f, '.depth'))" >> $LOGFILE
R --vanilla -e "f=\"$1\"; options(scipen=100); library(rtracklayer); x <- import(paste0(f, '.coverage.bedGraph')); w <- as.numeric(width(x)); s <- as.numeric(S4Vectors::mcols(x)[['score']]); writeLines(paste(c('depth:', 'mean_coverage:'), c(sum(w*s), weighted.mean(s, w))), paste0(f, '.depth'))"
# clean up
echo rm ${1}.coverage.bedGraph >> $LOGFILE
rm ${1}.coverage.bedGraph

# QC
echo qualimap bamqc -bam $1 -gd HUMAN -outdir output/QC -nt 4 -nr 10000 >> $LOGFILE
mkdir -p $2/QC
qualimap bamqc -bam $1 -gd HUMAN -outdir "$2/QC" -nt 4 -nr 10000
echo "samtools view -ub $1 | samstat -f bam -n ${1/.bam/}" >> $LOGFILE
samtools view -ub $1 | samstat -f bam -n ${1/.bam/}
mv "${1/.bam/}.html" "$2/QC/$(basename ${1/.bam/}).html"
echo `date`" - Finished processing $1" >> $LOGFILE

### 
module load gi/samtools/1.2
# $1=aligned/PrEC/TKCC20140214_PrEC_P6_Test_trimmed/TKCC20140214_PrEC_P6_Test_trimmed.bam
Lane=$(basename $1| cut -d. -f1)
# $2=aligned/PrEC/TKCC20140214_PrEC_P6_Test_trimmed/
OUTPUT=$2
LOGFILE=$OUTPUT/"$Lane".compute.statistics.log
# compute statistics
echo `date`" - Compute statistics" > $LOGFILE
echo "samtools flagstat $1 > $OUTPUT/${Lane}.flagstat" >> $LOGFILE
samtools flagstat $1 > "$OUTPUT/${Lane}.flagstat" 2>> $LOGFILE
echo `date`" - Finished compute flagstat" >> $LOGFILE

###
module load phuluu/python/2.7.8
BWAMETH="/share/ClusterShare/software/contrib/phuluu/bwa-meth"

# $1=aligned/PrEC/TKCC20140214_PrEC_P6_Test_trimmed/TKCC20140214_PrEC_P6_Test_trimmed.bam
Lane=$(basename $1| cut -d. -f1)
# $2=aligned/PrEC/TKCC20140214_PrEC_P6_Test_trimmed/
OUTPUT=$2
# /home/darloluu/methods/darlo/annotations/hg19/hg19.fa
GENOME=$3
LOGFILE=$OUTPUT/"$Lane".compute.statistics.log

echo `date`" - Assessing bias" >> $LOGFILE
python "$BWAMETH/bias-plot.py $1 $GENOME" >> $LOGFILE
python "$BWAMETH/bias-plot.py" $1 $GENOME 2>> $LOGFILE
echo `date`" - Finished compute statistics" >> $LOGFILE
