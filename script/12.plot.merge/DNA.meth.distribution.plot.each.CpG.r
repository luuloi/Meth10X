library(data.table)
library(ggplot2)
library(ggfortify)
library(rtracklayer)

# get inpath and outpath
options(echo=TRUE) 		# if you want see commands in output file
args <- commandArgs(trailingOnly = TRUE)

# args[1]="Test_Prostate/bigTable/QC/distributions"
# plot distribution of DNA methylation ratio for each CpG
INPATH <- paste0(args[1], "/")
cnames <- c("Group","Methylation", "Relative")
# single CpG sites
files <- paste0(INPATH, grep('*.distribution.Single_CpGs.tsv', dir(INPATH), value=T))
datalist <- lapply(files, function(x){tb <- fread(x); colnames(tb) <- cnames; return(tb)})
tb <- Reduce(function(x,y){rbind(x,y)}, datalist)
# ggplot(tb) + geom_line(aes(x=Methylation, y=Relative, colour=Group)) + xlab("Methylation Ratio") + ylab("Relative Frequency")
# ggplot(tb, aes(x=Methylation, weight=Relative/sum(Relative))) + xlab("Methylation Ratio") + ylab("Relative Frequency") + geom_histogram(aes(fill=Group))
ggplot(tb, aes(x=Methylation, weight=Relative/sum(Relative), colour=Group)) + xlab("Methylation Ratio") + ylab("Relative Frequency") + geom_density()
ggsave(paste0(INPATH, "Single_CpGs.svg"))
# all
files <- c('100bp', '1kb', '10kb', '100kb', 'CpGislands', 'CpGshores', 'others')
for (i in files) {
	fnames <- paste0(INPATH, grep(paste0('*.distribution.', i, '.tsv'), dir(INPATH), value=T))
	datalist <- lapply(fnames, function(x){tb <- fread(x); colnames(tb) <- cnames; return(tb)})
	tb <- Reduce(function(x,y){rbind(x,y)}, datalist)
	ggplot(tb, aes(x=Methylation, weight=Relative/sum(Relative), colour=Group)) + xlab("Methylation Ratio") + ylab("Relative Frequency") + geom_density()
	ggsave(paste0(INPATH, i, ".svg"))
}
