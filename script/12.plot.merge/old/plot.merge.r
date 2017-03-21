library(data.table)
library(ggplot2)
library(ggfortify)
library(rtracklayer)

# get inpath and outpath
options(echo=TRUE) 		# if you want see commands in output file
args <- commandArgs(trailingOnly = TRUE)

# args[1]="/home/darloluu/tmp/Test_Prostate/bigTables/bigTable.tsv"
# args[2]="/home/darloluu/tmp/Test_Prostate/bigTable/QC/"
INPUT1 <- args[1]
# "/home/darloluu/tmp/Test_Prostate/bigTables/QC/MDS/"
OUTPUT <- paste0(args[2], "/MDS/")
system(paste0("mkdir -p ", OUTPUT))

# MDS plot for single CpG sites
dt <- as.data.frame(fread(INPUT1))
samples <- gsub(".C$", "", grep("*.C$", colnames(dt), value=T))
cov <- paste0(samples,".cov")
tb <- dt[apply(dt[cov],1,function(x){all(x>0)}),]
nrow <- dim(tb)[1]
ntb <- sapply(samples, function(x){tb[,paste0(x,".C")]/tb[,paste0(x,".cov")]})
# make color
gg_color_hue <- function(n) {
	hues = seq(15, 375, length = n + 1)
	hcl(h = hues, l = 65, c = 100)[1:n]
}
cols = gg_color_hue(length(samples))

nrows <- round(nrow * c(0.08, 0.1, 1),0)
k <- 1
for(i in nrows){
	distm <- 1 - cor(ntb[1:i,])
	autoplot(cmdscale(distm, eig = TRUE), label = TRUE, label.colour=cols, label.size = 3) + xlab("") + ylab("") + ggtitle(paste0("MDS - top ", i, " sites"))
	ggsave(paste0(OUTPUT, "Single_CpGs.0", k, ".svg"))
	k <- k + 1
}

# MDS plot for smoothed
files <- c('100bp', '1kb', '10kb', '100kb')
# "/home/darloluu/tmp/Test_Prostate/bigTables/bw/smoothed/"
INPUT2 <- paste0(dirname(INPUT1), "/bw/smoothed/") 

for(i in files){
	bw <- paste0(INPUT2,grep(paste0('*.', i, '.bw'), list.files(INPUT2), value=T))
	datalist <- lapply(bw, function(x){
		a <- as.data.frame(score(import(x, format="bw")));
		colnames(a) <- gsub(paste0('*.', i, '.bw'),"",basename(x));
		return(a)})
	tb <- Reduce(function(x,y){cbind(x,y)}, datalist)
	samples <- colnames(tb)
	ntb <- tb[apply(tb,1,function(x){all(x>=0)}),]
	nrow <- dim(tb)[1]
	distm <- 1 - cor(ntb)
	# make color
	cols = gg_color_hue(length(samples))
	nrows <- round(nrow * c(0.08, 0.1, 1),0)
	k <- 1
	for(j in nrows){
		autoplot(cmdscale(distm, eig = TRUE), label = TRUE, label.colour=cols, label.size = 3) + xlab("") + ylab("") + ggtitle(paste0("MDS - top ", j, " sites"))
		ggsave(paste0(OUTPUT, i, ".0", k, ".svg"))
		k <- k + 1
	}
}

# plot distribution of DNA methylation ratio for each CpG
# '/home/darloluu/tmp/Test_Prostate/bigTables/QC/distributions/'
INPATH <- paste0(args[2], "/distributions/") 
cnames <- c("Group","Methylation", "Relative")
# single CpG sites
files <- paste0(INPATH, grep('*.distribution.Single_CpGs.tsv', dir(INPATH), value=T))
datalist <- lapply(files, function(x){tb <- fread(x); colnames(tb) <- cnames; return(tb)})
tb <- Reduce(function(x,y){rbind(x,y)}, datalist)
ggplot(tb) + geom_line(aes(x=Methylation, y=Relative, colour=Group)) + xlab("Methylation Ratio") + ylab("Relative Frequency")
ggsave(paste0(INPATH, "Single_CpGs.svg"))
# all
files <- c('100bp', '1kb', '10kb', '100kb', 'CpGislands', 'CpGshores', 'others')
for (i in files) {
	fnames <- paste0(INPATH, grep(paste0('*.distribution.', i, '.tsv'), dir(INPATH), value=T))
	datalist <- lapply(fnames, function(x){tb <- fread(x); colnames(tb) <- cnames; return(tb)})
	tb <- Reduce(function(x,y){rbind(x,y)}, datalist)
	ggplot(tb) + geom_line(aes(x=Methylation, y=Relative, colour=Group)) + xlab("Methylation Ratio") + ylab("Relative Frequency")
	ggsave(paste0(INPATH, i, ".svg"))
}
system(paste0("mv ", INPATH, "CpGislands.svg ", INPATH, "CpG_Islands.svg"))
system(paste0("mv ", INPATH, "CpGshores.svg ", INPATH, "CpG_Shores.svg"))
system(paste0("mv ", INPATH, "others.svg ", INPATH, "CpG_Non_Island.svg"))

# whole genome CpG coverage for all samples
# "/home/darloluu/tmp/Test_Prostate/bigTables/QC/per-sample/"
sample.CpG.coverage <- paste0(dirname(INPUT1), "/QC/per-sample/")
sample.CpG.coverage.output <- args[2]
files <- paste0(sample.CpG.coverage, grep("*.CpG.coverage.tsv", list.files(sample.CpG.coverage), value=T))
depth <- 60
hline <- c(25, 50, 75, 90, 95)
vline <- c(2, 5, 10, 15, 20, 25, 30, 40)
df <- lapply(files, function(x){read.table(x, header=1)})
tb <- Reduce(function(x,y){rbind(x,y)}, df)
# Plot 
ggplot(data=tb, aes(x=Depth, y=Fraction, colour=Sample)) +
geom_line(size = 1) +       # Line type depends on cond # Thicker line
geom_point(size = 4) +      # Shape depends on cond
xlab('Depth') + ylab('Fraction of base at this depth or better (%)') + ggtitle('CpG Depth and Coverage') +
xlim(0,depth) + ylim(0,100) + geom_vline(xintercept = vline, colour="gray", linetype = "longdash") + 
geom_hline(yintercept = hline, colour="gray", linetype = "longdash") +
theme(text=element_text(size=15, face = "bold"), legend.text=element_text(size=15, face = "bold")) + 
guides(colour = guide_legend(override.aes = list(size=8)))
ggsave(filename=paste0(sample.CpG.coverage.output, "/", "CpG.coverage.svg"), width = 12, height = 14)


# merge CpG bias
CpG.bias.path <- args[2]
cnames <- c("Group", "CpGislands", "CpGshores", "Other", "CpGislands.bias", "CpGshores.bias")
files <- grep('*.CpG_bias.tsv', list.files(CpG.bias.path), value=T)
datalist <- lapply(paste(CpG.bias.path, "/", files, sep=""), function(x){tb <- read.table(x); colnames(tb) <- cnames; return(tb)})
tb <- Reduce(function(x,y){rbind(x,y)}, datalist)
write.table(tb, file=paste0(CpG.bias.path, "/", "CpG_bias.tsv"), sep="\t", row.names=F)
