# get inpath and outpath
options(echo=TRUE) 		# if you want see commands in output file
args <- commandArgs(trailingOnly = TRUE)

# args[1]="/home/darloluu/tmp/Test_Prostate/bigTables/QC/distributions/"
# args[2]="/home/darloluu/tmp/Test_Prostate/bigTable/QC/"

# merge CpG bias
inpath <- args[1]
outpath <- args[2]
cnames <- c("Group", "CpGislands", "CpGshores", "Other", "CpGislands.bias", "CpGshores.bias")
files <- grep("*.CpG_bias.tsv$", list.files(inpath), value=T)
datalist <- lapply(paste(inpath, "/", files, sep=""), function(x){tb <- read.table(x); colnames(tb) <- cnames; return(tb)})
tb <- Reduce(function(x,y){rbind(x,y)}, datalist)
write.table(tb, file=paste0(outpath, "/", "CpG_bias.tsv"), sep="\t", row.names=F)
