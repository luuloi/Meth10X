#!bin/bash

module load gi/bedtools/2.22.0
module load phuluu/R/3.1.2

INPUT="/home/darloluu/tmp/Test_Prostate/called/PrEC/PrEC.CpG.tsv.gz"
# INPUT=$1
OUTPUT="/home/darloluu/tmp/Test_Prostate/bigTables/QC/per-sample"
# OUTPUT=$2
sample="PrEC"
# sample=$3
CpGislands="/home/darloluu/methods/darlo/annotations/hg19/hg19.CpGislands.tsv"
# CpGislands=$4
CpGshores="/home/darloluu/methods/darlo/annotations/hg19/hg19.CpGshores.tsv"
# CpGshores=$5
others="/home/darloluu/methods/darlo/annotations/hg19/hg19.others.tsv"
# others=$6
GSIZE="/home/darloluu/methods/darlo/annotations/hg19/hg19.chrom.sizes.short"
# GSIZE=$7
minCov=1
mkdir -p $OUTPUT
LOGFILE="$OUTPUT/${sample}.CpGibias.and.compute.distribution.log"

echo "CpGibias.and.compute.distribution.bash" > "$LOGFILE"
echo `date`" - Started processing $1 on $HOSTNAME" >> "$LOGFILE"

echo `date`" - Compute CpG methylation distribution" >> "$LOGFILE"

gunzip -c $INPUT| awk '{OFS="\t"}{print $1,$4}' > ${INPUT/.gz/}
nrow=$(wc -l ${INPUT/.gz/}| awk '{print $1}')
echo -e "Sample\tDepth\tFraction" > "$OUTPUT/$sample.CpG.coverage.tsv"
awk '{print $2}' ${INPUT/.gz/}| sort| uniq -c| awk -v nrow=$nrow -v sample=$sample '{OFS="\t"}{print sample,$2,100*$1/nrow}' >> "$OUTPUT/$sample.CpG.coverage.tsv"

# whole genome CpG coverage
R
library(ggplot2)
depth <- 60
hline <- c(25, 50, 75, 90, 95)
vline <- c(2, 5, 10, 15, 20, 25, 30, 40)
df1 <- read.table("/home/darloluu/tmp/Test_Prostate/bigTables/QC/per-sample/PrEC.CpG.coverage.tsv", header=1)
# Plot 
ggplot(data=df1, aes(x=Depth, y=Fraction)) +
geom_line(size = 1) +       # Line type depends on cond # Thicker line
geom_point(size = 4) +      # Shape depends on cond
xlab('Depth') + ylab('Fraction of base at this depth or better (%)') + ggtitle('CpG Depth and Coverage') +
xlim(0,depth) + ylim(0,100) + geom_vline(xintercept = vline, colour="gray", linetype = "longdash") + 
geom_hline(yintercept = hline, colour="gray", linetype = "longdash") +
theme(text=element_text(size=15, face = "bold"), legend.text=element_text(size=15, face = "bold")) + 
guides(colour = guide_legend(override.aes = list(size=8)))
ggsave(filename=paste0("/home/darloluu/tmp/Test_Prostate/bigTables/QC/per-sample", "/", "PrEC.CpG.coverage.svg"), width = 10, height = 11)

# CpG coverage for each chromosome
R
library(data.table)
library(ggplot2)
sample <- "PrEC"
tb <- fread("/home/darloluu/tmp/Test_Prostate/called/PrEC/PrEC.CpG.tsv")
colnames(tb) <- c("Chromosome", "CpG.Coverage")
tb$Chromosome <- factor(tb$Chromosome)
# plot
ggplot(data=tb) + geom_boxplot(aes(x=Chromosome, y=CpG.Coverage)) +
ylab('Time coverage') + ggtitle(paste0(sample, ' - CpG Coverage')) +
theme(text=element_text(size=15, face = "bold"), legend.text=element_text(size=15, face = "bold"), axis.text.x = element_text(angle = 90, hjust = 1)) + 
guides(colour = guide_legend(override.aes = list(size=8)))
ggsave(filename=paste0("/home/darloluu/tmp/Test_Prostate/bigTables/QC/per-sample", "/", sample, ".chromosome.CpG.coverage.png"), width = 12, height = 8)

# plot CpG bias boxplot
R
library(data.table)
library(ggplot2)
sample <- "PrEC"
tb <- fread("/home/darloluu/tmp/Test_Prostate/bigTables/QC/distributions/PrEC.CpG.bias.plot.tsv")
colnames(tb) <- c("Regions", "CpG.Coverage")
tb$Chromosome <- factor(tb$Regions)
# plot
ggplot(data=tb) + geom_boxplot(aes(x=Regions, y=CpG.Coverage)) +
ylab('Time coverage') + ggtitle(paste0(sample, ' - CpG Coverage')) +
theme(text=element_text(size=15, face = "bold"), legend.text=element_text(size=15, face = "bold"), axis.text.x = element_text(angle = 90, hjust = 1)) + 
guides(colour = guide_legend(override.aes = list(size=8)))
ggsave(filename=paste0("/home/darloluu/tmp/Test_Prostate/bigTables/QC/per-sample", "/", sample, ".CpG.bias.png"), width = 10, height = 8)

