library(Biostrings)
library(GenomicRanges)
library(rtracklayer)

path <-"/home/phuluu/Projects/WGBS10X_new/V02/annotations/hg19/lambda.fa"
lambda <- readDNAStringSet(path)[[1]]

# FW strand Cs
C.FW <- matchPattern("C", lambda, fixed=TRUE)

# RV strand Cs
C.RV <- matchPattern("G", lambda, fixed=TRUE)

# Make GRanges
lambda <- GRanges("lambda", IRanges(c(start(C.FW), start(C.RV)), width=1),
	strand=rep(c("+", "-"), c(length(C.FW), length(C.RV))))

# Sort and initialise C and cov columns
lambda <- lambda[order(as.factor(seqnames(lambda)), start(lambda), as.factor(strand(lambda)))]
values(lambda)$cov <- values(lambda)$C <- 0
export(lambda, gsub(".fa", ".C.strands.bed", path), format=".bed")
# Save
# save(lambda, file="lambda.C.Rdata")
