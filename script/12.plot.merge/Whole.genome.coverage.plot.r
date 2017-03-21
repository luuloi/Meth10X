library(ggplot2)


# get inpath and outpath
options(echo=TRUE) 		# if you want see commands in output file
args <- commandArgs(trailingOnly = TRUE)

# whole genome CpG coverage for all samples
# args[1]="/home/darloluu/tmp/Test_Prostate/bigTables/bigTable.tsv"
# args[2]="/home/darloluu/tmp/Test_Prostate/bigTable/QC/"
# "/home/darloluu/tmp/Test_Prostate/bigTables/QC/per-sample/"

depth <- 60
hline <- c(25, 50, 75, 90, 95)
vline <- c(2, 5, 10, 15, 20, 25, 30, 40)

samples <- dir("merged")
dt <- lapply(samples, function(x){
	tb <- read.table(paste0("merged/",x,"/QC/genome_coverage.tsv"), header=T)
	tmp <- 100 - cumsum(tb$Fraction)
	tb$Frequency <- c(100, tmp[1:length(tmp)-1])
	return(tb)
	})
dt1 <- do.call(rbind,dt)
# dt <- Reduce(function(x, y) merge(x, y, by="Depth"), tb)

# Plot 
ggplot(data=dt1, aes(x=Depth, y=Frequency, colour=Sample)) +
geom_line(size = 1) +       # Line type depends on cond # Thicker line
geom_point(size = 4) +      # Shape depends on cond
xlab('Depth') + ylab('Fraction of base at this depth or better (%)') + ggtitle('Whole genome sites Depth and Breadth Coverage') +
xlim(0,depth) + ylim(0,100) + geom_vline(xintercept = vline, colour="gray", linetype = "longdash") + 
geom_hline(yintercept = hline, colour="gray", linetype = "longdash") +
theme(text=element_text(size=15, face = "bold"), legend.text=element_text(size=15, face = "bold")) + 
guides(colour = guide_legend(override.aes = list(size=8)))
ggsave(filename=paste0("bigTable/QC/", "whole.genome.coverage.svg"), width = 12, height = 14)


### example
# samples <- "5060_bis_6_CEGX"
