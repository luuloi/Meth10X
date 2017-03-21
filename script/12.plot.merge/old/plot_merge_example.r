module load phuluu/R/3.1.2

R
library(data.table)
library(ggplot2)

INPATH <- '/home/darloluu/tmp/Test_Prostate/bigTables/QC/distributions/'
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
system(paste0("mv ", INPATH, "others.svg ", INPATH, "CpG_Non_Island.svg"))


# MDS plot for single CpG sites
R
library(data.table)
library(ggplot2)
library(ggfortify)
library(rtracklayer)

INPUT1 <- "/home/darloluu/tmp/Test_Prostate/bigTables/bigTable.tsv"
OUTPUT <- "/home/darloluu/tmp/Test_Prostate/bigTables/QC/MDS/"
system(paste0("mkdir -p ", OUTPUT))

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
library(rtracklayer)

files <- c('100bp', '1kb', '10kb', '100kb')
INPUT2 <- "/home/darloluu/tmp/Test_Prostate/bigTables/bw/smoothed/"

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

# merge CpG bias
INPATH <- '/home/darloluu/tmp/Test_Prostate/bigTables/QC'
cnames <- c("Group", "CpGislands", "CpGshores", "Other", "CpGislands.bias", "CpGshores.bias")
files <- grep('*.CpG_bias.tsv', dir(INPATH), value=T)
datalist <- lapply(paste(INPATH, "/", files, sep=""), function(x){tb <- read.table(x); colnames(tb) <- cnames; return(tb)})
tb <- Reduce(function(x,y){rbind(x,y)}, datalist)
write.table(tb, file=paste0(INPATH, "/", "CpG_bias.tsv"), sep="\t", row.names=F)

# whole genome CpG coverage for all sample
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