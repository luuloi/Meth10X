message(Sys.time(), " - Executing 'make_genome_tsv.R' on ", Sys.info()["nodename"])
#
# Usage: R -f make_genome_granges.R --args [genome] [transcriptome GTF] [outpath] ["transcript_biotype"/"source"]
#

#
# Check command line arguments
#
stopifnot(length(commandArgs(TRUE))==4)

# Check GTF exists
# stopifnot(file.exists(commandArgs(TRUE)[2]))

# Check tx_type argument
stopifnot(commandArgs(TRUE)[4] %in% c("transcript_biotype", "source"))

# outpath
outpath <- commandArgs(TRUE)[3]

# Find the appropriate BSgenome package
build.name <- commandArgs(TRUE)[1]
packages <- installed.packages()[,"Package"]
bs.build <- grep(paste0("^BSgenome.*UCSC.", build.name), packages)
stopifnot(length(bs.build)==1)
library(packages[bs.build], character.only=TRUE)
# get object of the build
build <- get(sub("BSgenome.", "", gsub(".UCSC.*", "", packages[bs.build])))
# remove any _random or _hap chromosomes
chrs <- seqnames(build)
chrs <- chrs[!grepl("_random|_hap|_alt", chrs)]

#
# WGBS GRanges table - find all CpGs and CpHs on both strands
#
CpG <- resize(vmatchPattern("CG", build), 1, fix="start")

CHG <- resize(c(vmatchPattern("CAG", build),
                vmatchPattern("CCG", build),
                vmatchPattern("CTG", build)), 1, fix="start")

CHA <- resize(c(vmatchPattern("CAA", build),
                vmatchPattern("CCA", build),
                vmatchPattern("CTA", build)),1, fix="start")

CHC <- resize(c(vmatchPattern("CAC", build),
				vmatchPattern("CCC", build),
				vmatchPattern("CTC", build)), 1, fix="start")

CHT <- resize(c(vmatchPattern("CAT", build),
				vmatchPattern("CCT", build),
				vmatchPattern("CTT", build)), 1, fix="start")

# Interleave + and - strand
CpG <- CpG[order(as.factor(seqnames(CpG)), start(CpG), as.factor(strand(CpG)))]
CHG <- CHG[order(as.factor(seqnames(CHG)), start(CHG), as.factor(strand(CHG)))]
CHA <- CHA[order(as.factor(seqnames(CHA)), start(CHA), as.factor(strand(CHA)))]
CHC <- CHC[order(as.factor(seqnames(CHC)), start(CHC), as.factor(strand(CHC)))]
CHT <- CHT[order(as.factor(seqnames(CHT)), start(CHT), as.factor(strand(CHT)))]

# Force CpG sites to not overlap
CpG <- resize(CpG, 1, fix="start")
CHG <- resize(CHG, 1, fix="start")
CHA <- resize(CHA, 1, fix="start")
CHC <- resize(CHC, 1, fix="start")
CHT <- resize(CHT, 1, fix="start")
# Initialise 0s
# values(CpG)$cov <- values(CpG)$C <- values(CHG)$cov <- values(CHG)$C <- values(CHH)$cov <- values(CHH)$C <- 0L

# Save positions
genome(CpG) <- genome(CHG) <- genome(CHA) <- genome(CHC) <- genome(CHT) <- build.name
seqlevels(CpG, force=TRUE) <- seqlevels(CHG, force=TRUE) <- seqlevels(CHA, force=TRUE) <- seqlevels(CHC, force=TRUE) <- seqlevels(CHT, force=TRUE) <- chrs
# seqlevels(CpG, pruning.mode="coarse") <- seqlevels(CHG, pruning.mode="coarse") <- seqlevels(CHH, pruning.mode="coarse") <- chrs
seqlengths(CpG) <- seqlengths(CHG) <- seqlengths(CHA) <- seqlengths(CHC) <- seqlengths(CHT) <- seqlengths(build)[chrs]
# save(CpG, CpH, file=paste0(build.name, ".WGBS.Rdata"))
library(rtracklayer)
export(CpG, paste0(outpath, build.name, '.CpG.strands.bed'), format='bed')
export(CHG, paste0(outpath, build.name, '.CHG.strands.bed'), format='bed')
export(CHA, paste0(outpath, build.name, '.CHA.strands.bed'), format='bed')
export(CHC, paste0(outpath, build.name, '.CHC.strands.bed'), format='bed')
export(CHT, paste0(outpath, build.name, '.CHT.strands.bed'), format='bed')


rm(CpG, CHG, CHA, CHC, CHT)

# output generate
# head data/annotations/hg19/hg19.CpG.strands.bed
# chr1	10468	10469	.	0	+
# chr1	10469	10470	.	0	-
# chr1	10470	10471	.	0	+
# head data/annotations/hg19/hg19.CHG.strands.bed
# chr1	10472	10473	.	0	-
# chr1	10479	10480	.	0	+
# chr1	10481	10482	.	0	-
# less data/annotations/hg19/hg19.CHH.strands.bed
# chr1    11315   11316   .       0       +
# chr1    11316   11317   .       0       +
# chr1    11318   11319   .       0       +
# chr1    11321   11322   .       0       -
# chr1    11322   11323   .       0       +
# chr1    11333   11334   .       0       -
# chr1    11335   11336   .       0       -


# #
# # NOMe GRanges table - find all WCGs, GCHs and HCHs on both strands
# #
# GCH <- resize(c(vmatchPattern("GCA", build),
#                 vmatchPattern("GCC", build),
#                 vmatchPattern("GCT", build)), 1, fix="center")
# WCG <- resize(c(vmatchPattern("ACG", build),
#                 vmatchPattern("TCG", build)), 1, fix="center")
# HCH <- resize(c(vmatchPattern("ACA", build),
#                 vmatchPattern("CCA", build),
#                 vmatchPattern("TCA", build),
#                 vmatchPattern("ACC", build),
#                 vmatchPattern("CCC", build),
#                 vmatchPattern("TCC", build),
#                 vmatchPattern("ACT", build),
#                 vmatchPattern("CCT", build),
#                 vmatchPattern("TCT", build)), 1, fix="center")

# # Interleave + and - strand
# GCH <- GCH[order(as.factor(seqnames(GCH)), start(GCH), as.factor(strand(GCH)))]
# WCG <- WCG[order(as.factor(seqnames(WCG)), start(WCG), as.factor(strand(WCG)))]
# HCH <- HCH[order(as.factor(seqnames(HCH)), start(HCH), as.factor(strand(HCH)))]
# GCH$cov <- GCH$C <- WCG$cov <- WCG$C <- HCH$cov <- HCH$C <- 0L

# # Save positions
# genome(GCH) <- genome(WCG) <- genome(HCH) <- build.name
# # seqlevels(GCH, force=TRUE) <- seqlevels(WCG, force=TRUE) <- seqlevels(HCH, force=TRUE) <- chrs
# seqlevels(GCH, pruning.mode="coarse") <- seqlevels(WCG, pruning.mode="coarse") <- seqlevels(HCH, pruning.mode="coarse") <- chrs
# seqlengths(GCH) <- seqlengths(WCG) <- seqlengths(HCH) <- seqlengths(build)[chrs]
# save(GCH, WCG, HCH, file=paste0(build.name, ".NOMe.Rdata"))
# rm(GCH, WCG, HCH)

# #
# # Export genome sequence as a fasta
# #
# writeXStringSet(DNAStringSet(as.list(build)[chrs]), paste0(build.name, ".fa"))

# #
# # Retrieve CpG islands from UCSC
# #
# library(rtracklayer)
# session <- browserSession()
# genome(session) <- build.name
# query <- ucscTableQuery(session, "cpgIslandExt")
# CpGislands <- as(track(query), "GRanges")
# genome(CpGislands) <- build.name
# # seqlevels(CpGislands, force=TRUE) <- chrs
# seqlevels(CpGislands, pruning.mode="coarse") <- chrs
# seqlengths(CpGislands) <- seqlengths(build)[chrs]

# # Calculate CpG island shores & 5kb
# CpGshores <- setdiff(resize(CpGislands, width(CpGislands)+4000, fix="center"), CpGislands)
# CpG5kb <- resize(CpGislands, 5000)

# # Save positions
# save(CpGislands, CpGshores, CpG5kb, file=paste0(build.name, ".CpGislands.Rdata"))

# #
# # Make transcript object 
# #
# library(aaRon)
# tx <- makeTx(commandArgs(TRUE)[2], build, commandArgs(TRUE)[3])
# genome(tx) <- build.name
# # seqlevels(tx, force=TRUE) <- chrs
# seqlevels(tx, pruning.mode="coarse") <- chrs
# save(tx, file=paste0(build.name, ".tx.Rdata"))

sessionInfo()
