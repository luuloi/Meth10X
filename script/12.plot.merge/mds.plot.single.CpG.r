library(data.table)
library(ggplot2)
library(ggfortify)
library(rtracklayer)

# get inpath and outpath
options(echo=TRUE) 		# if you want see commands in output file
args <- commandArgs(trailingOnly = TRUE)

# args[1]="/home/darloluu/tmp/Test_Prostate/bigTables/bigTable.tsv"
# args[2]="/home/darloluu/tmp/Test_Prostate/bigTable/QC/MDS/"
# example
# INPUT <- "/home/phuluu/data/WGBS10X_new/Test_Prostate/bigTable/bigTable.tsv"
# OUTPUT <- "/home/phuluu/data/WGBS10X_new/Test_Prostate/bigTable/QC/MDS/"
# dt <- as.data.frame(fread(INPUT))

INPUT <- args[1]
# "/home/darloluu/tmp/Test_Prostate/bigTables/QC/MDS/"
OUTPUT <- paste0(args[2], "/")
system(paste0("mkdir -p ", OUTPUT))

# MDS plot for single CpG sites
dt <- as.data.frame(fread(INPUT))
samples <- gsub(".C$", "", grep("*.C$", colnames(dt), value=T))
if(length(unique(samples))<3) stop("Less than 3 samples, don't need a MDS plot")
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
	# autoplot(cmdscale(distm, eig = TRUE), label = TRUE, label.colour=cols, label.size = 3) + xlab("") + ylab("") + ggtitle(paste0("MDS - top ", i, " sites"))
	tryCatch( autoplot(cmdscale(distm, eig = TRUE), label = TRUE, label.colour=cols, label.size = 3) + xlab("") + ylab("") + ggtitle(paste0("MDS - top ", i, " sites")),
    	error = function(c) { 
    		autoplot(cmdscale(distm), label = TRUE, label.colour=cols, label.size = 3) + xlab("") + ylab("") + ggtitle(paste0("MDS - top ", i, " sites"))
    	}
  	)
	ggsave(paste0(OUTPUT, "Single_CpGs.0", k, ".svg"))
	k <- k + 1
}
