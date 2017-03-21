library(data.table)
library(ggplot2)
library(ggfortify)
library(rtracklayer)

# get inpath and outpath
options(echo=TRUE) 		# if you want see commands in output file
args <- commandArgs(trailingOnly = TRUE)
# args[1]="/home/darloluu/tmp/Test_Prostate/bigTables/bigTable.tsv"
# args[2]="/home/darloluu/tmp/Test_Prostate/bigTable/QC/MDS/"

# MDS plot for smoothed
files <- c('100bp', '1kb', '10kb', '100kb')
# "/home/darloluu/tmp/Test_Prostate/bigTable/bw/smoothed/"
INPUT2 <- paste0(dirname(args[1]), "/bw/smoothed/") 
OUTPUT <- paste0(args[2], "/")

gg_color_hue <- function(n) {
	hues = seq(15, 375, length = n + 1)
	hcl(h = hues, l = 65, c = 100)[1:n]
}

for(i in files){
	bw <- paste0(INPUT2,grep(paste0('*.', i, '.bw'), list.files(INPUT2), value=T))
	datalist <- lapply(bw, function(x){
		a <- as.data.frame(score(import(x, format="bw")));
		colnames(a) <- gsub(paste0('*.', i, '.bw'),"",basename(x));
		return(a)})
	tb <- Reduce(function(x,y){cbind(x,y)}, datalist)
	samples <- colnames(tb)
	if(length(unique(samples))<3) stop("Less than 3 samples, don't need a MDS plot")
	ntb <- tb[apply(tb,1,function(x){all(x>=0)}),]
	nrow <- dim(tb)[1]
	distm <- 1 - cor(ntb)
	# make color
	cols = gg_color_hue(length(samples))
	nrows <- round(nrow * c(0.08, 0.1, 1),0)
	k <- 1
	for(j in nrows){
		tryCatch( autoplot(cmdscale(distm, eig = TRUE), label = TRUE, label.colour=cols, label.size = 3) + xlab("") + ylab("") + ggtitle(paste0("MDS - top ", j, " sites")),
			error = function(c) { 
				autoplot(cmdscale(distm), label = TRUE, label.colour=cols, label.size = 3) + xlab("") + ylab("") + ggtitle(paste0("MDS - top ", j, " sites"))
			}
		)
		ggsave(paste0(OUTPUT, i, ".0", k, ".svg"))
		k <- k + 1
	}
}
