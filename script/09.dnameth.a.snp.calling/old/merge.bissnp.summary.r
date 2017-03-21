# get inpath and outpath
options(echo=TRUE) 		# if you want see commands in output file
args <- commandArgs(trailingOnly = TRUE)
# "/home/darloluu/tmp/Test_Prostate/called/LNCaP/LNCaP.tmp.meth.vcf.MethySummarizeList.txt"
INPUT <- args[1]
# "/home/darloluu/tmp/Test_Prostate/called/LNCaP/LNCaP.meth.vcf.MethySummarizeList.txt"
OUTPUT <- args[2]

tb <- read.table(INPUT)
tb[,"V3"] <- as.numeric(sub("%", "", tb[,"V3"]))
for(i in c("CG:","CH:")){
	ind <- tb$V1==i
	Cp.count <- sum(tb[ind,"V2"])
	Cp.meth.percent <- sum(tb[ind,"V2"]*tb[ind,"V3"])/Cp.count
	cat(paste(i, Cp.count, paste0(Cp.meth.percent, "%"), sep="\t"), file=OUTPUT, append=TRUE, sep="\n")
}
