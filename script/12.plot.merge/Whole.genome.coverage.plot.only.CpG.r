library(data.table)
library(ggplot2)
library(ggfortify)
library(rtracklayer)

# get inpath and outpath
options(echo=TRUE) 		# if you want see commands in output file
args <- commandArgs(trailingOnly = TRUE)

# whole genome CpG coverage for all samples
# args[1]="/home/darloluu/tmp/Test_Prostate/bigTables/bigTable.tsv"
# args[2]="/home/darloluu/tmp/Test_Prostate/bigTable/QC/"
# "/home/darloluu/tmp/Test_Prostate/bigTables/QC/per-sample/"
sample.CpG.coverage <- paste0(dirname(args[1]), "/QC/per-sample/")
sample.CpG.coverage.output <- args[2]
files <- paste0(sample.CpG.coverage, grep("*.CpG.coverage.tsv", list.files(sample.CpG.coverage), value=T))
depth <- 60
hline <- c(25, 50, 75, 90, 95)
vline <- c(2, 5, 10, 15, 20, 25, 30, 40)
df <- lapply(files, function(x){
	tb <- read.table(x, header=1)
	tmp <- 100 - cumsum(tb$Fraction)
	tb$Frequency <- c(100, tmp[1:length(tmp)-1])
	return(tb)
})
tb <- Reduce(function(x,y){rbind(x,y)}, df)
# tb <- Reduce(function(x, y) merge(x, y, by="Depth"), df)
# Plot 
ggplot(data=tb, aes(x=Depth, y=Frequency, colour=Sample)) +
geom_line(size = 1) +       # Line type depends on cond # Thicker line
geom_point(size = 4) +      # Shape depends on cond
xlab('Depth') + ylab('Fraction of base at this depth or better (%)') + ggtitle('CpG sites Depth and Breadth Coverage') +
xlim(0,depth) + ylim(0,100) + geom_vline(xintercept = vline, colour="gray", linetype = "longdash") + 
geom_hline(yintercept = hline, colour="gray", linetype = "longdash") +
theme(text=element_text(size=15, face = "bold"), legend.text=element_text(size=15, face = "bold")) + 
guides(colour = guide_legend(override.aes = list(size=8)))
ggsave(filename=paste0(sample.CpG.coverage.output, "/", "CpG.coverage.svg"), width = 12, height = 14)

# example
# cd ~/data/WGBS10X_new/Prostate_Brain/called
# tb <- read.table("cov.tsv")
# tmp <- 100 - cumsum(tb$V3)
# tb$V4 <- c(100, tmp[1:length(tmp)-1])
# ggplot(data=tb, aes(x=V2, y=V4, colour=V1)) + xlim(0,10) + ylim(0,100) + geom_line(size = 1)
