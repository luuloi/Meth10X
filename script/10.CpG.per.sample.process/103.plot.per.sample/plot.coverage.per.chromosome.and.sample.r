library(data.table)
library(ggplot2)

# get inpath and outpath
options(echo=TRUE) 		# if you want see commands in output file
args <- commandArgs(trailingOnly = TRUE)
# "/home/phuluu/data/Test_Prostate/bigTable/QC/distributions/PrEC.CpG.coverage.per.chrom.tsv
chromosome.CpG.coverage <- args[1]
# "/home/phuluu/data/Test_Prostate/bigTable/QC/per-sample/PrEC.CpG.coverage.tsv"
sample.CpG.coverage.path <- args[2]
# "/home/phuluu/data/Test_Prostate/bigTable/QC/distributions/PrEC.CpG.bias.plot.tsv"
sample.CpG.bias.plot <- args[3]
sample <- args[4]
# "/home/darloluu/tmp/Test_Prostate/bigTables/QC/per-sample"
output.per.sample <- dirname(sample.CpG.coverage.path)

# CpG coverage for each chromosome
tb <- read.table(chromosome.CpG.coverage, header=1)
# colnames(tb) <- c("Chromosome", "CpG.Coverage")
# tb$Chromosome <- factor(tb$Chromosome)
# plot
# ggplot(data=tb) + geom_boxplot(aes(x=Chromosome, y=CpG.Coverage)) +
ggplot(tb, aes(x=Chrom, y=Coverage, weight=Frequency)) + geom_violin() + 
ylab('Time coverage') + xlab('') + ggtitle(paste0(sample, ' - CpG Coverage per chromosome')) +
theme(text=element_text(size=15, face = "bold"), legend.text=element_text(size=15, face = "bold"), axis.text.x = element_text(angle = 90, hjust = 1)) + 
guides(colour = guide_legend(override.aes = list(size=8)))
ggsave(filename=paste0(output.per.sample, "/", sample, ".chromosome.CpG.coverage.png"), width = 12, height = 8)

# whole genome CpG coverage
depth <- 60
hline <- c(25, 50, 75, 90, 95)
vline <- c(2, 5, 10, 15, 20, 25, 30, 40)
df <- read.table(sample.CpG.coverage.path, header=1)
# Plot 
ggplot(data=df, aes(x=Depth, y=Fraction)) +
geom_line(size = 1) +       # Line type depends on cond # Thicker line
geom_point(size = 4) +      # Shape depends on cond
xlab('Depth') + ylab('Fraction of base at this depth or better (%)') + ggtitle(paste0(sample, ' - CpG Depth and Coverage')) +
xlim(0,depth) + ylim(0,100) + geom_vline(xintercept = vline, colour="gray", linetype = "longdash") + 
geom_hline(yintercept = hline, colour="gray", linetype = "longdash") +
theme(text=element_text(size=15, face = "bold"), legend.text=element_text(size=15, face = "bold")) + 
guides(colour = guide_legend(override.aes = list(size=8)))
ggsave(filename=paste0(output.per.sample, "/", sample, ".CpG.coverage.svg"), width = 10, height = 11)

# plot CpG bias boxplot
tb <- read.table(sample.CpG.bias.plot, header=1)
# colnames(tb) <- c("Regions", "Coverage", "Frequency")
# tb$Chromosome <- factor(tb$Regions)
# plot
# ggplot(data=tb) + geom_boxplot(aes(x=Regions, y=CpG.Coverage)) +
ggplot(tb, aes(x=Regions, y=Coverage, weight=Frequency)) + geom_violin() + 
ylab('Time coverage') + xlab('') + ggtitle(paste0(sample, ' - CpG Coverage')) +
theme(text=element_text(size=15, face = "bold"), legend.text=element_text(size=15, face = "bold"), axis.text.x = element_text(angle = 90, hjust = 1)) + 
guides(colour = guide_legend(override.aes = list(size=8)))
ggsave(filename=paste0(output.per.sample, "/", sample, ".CpG.bias.png"), width = 10, height = 8)
