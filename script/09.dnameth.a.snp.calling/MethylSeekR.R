# Rscript MethylSeekR.R build.name annotation.prefix bigTable.path output.dir sample
# run this R script
# R -f MethylSeekR.R --args build.name annotation.prefix bigTable.path output.dir sample
# R -f ~/Projects/WGBS10X_new/V02/script/09.dnameth.a.snp.calling/MethylSeekR.R --args hg19 \
#                                                                                      /home/phuluu/Projects/WGBS10X_new/V02/annotations/hg19/ \
#                                                                                      called/PrEC/PrEC.MD_CpG.tsv \
#                                                                                      bigTable/bw/MethylSeekR/ \
#                                                                                      PrEC
message(Sys.time(), " - Executing 'MethylSeekR.R' on ", Sys.info()["nodename"])
stopifnot(length(commandArgs(TRUE))==5)
# build.name <- "hg19" 
build.name <- commandArgs(TRUE)[1]
packages <- installed.packages()[,"Package"]
bs.build <- grep(paste0("^BSgenome.*UCSC.", build.name), packages)
stopifnot(length(bs.build)>0)
library(packages[bs.build[1]], character.only=TRUE)
# get object of the build
build <- get(sub("BSgenome.", "", gsub(".UCSC.*", "", packages[bs.build[1]])))

library(data.table)
library(GenomicRanges)
library(rtracklayer)
library(MethylSeekR)


# load
# convert beds to bigBeds
# bedToBigBed <- "/home/phuluu/bin/ucsc/bedToBigBed"
# /home/phuluu/Projects/WGBS10X_new/V02/annotations/hg19/hg19.CpG5kb.bed
# annotation.prefix <- "/home/phuluu/Projects/WGBS10X_new/V02/annotations/"
annotation.prefix <- commandArgs(TRUE)[2]
CpG5kb <- import(paste0(annotation.prefix, "/", build.name, ".CpG5kb.bed"), format="bed")

# Load CpG & GCH bigTable
# bigTable.path <- "/home/phuluu/data/WGBS10X_new/Test_Prostate/called/LNCaP/LNCaP.MD_CpG.tsv"
bigTable.path <-  commandArgs(TRUE)[3]
tab <- fread(bigTable.path)
colnames(tab) <- gsub("#", "", colnames(tab))
CpGs <- GRanges(tab$chr, IRanges(tab$position, width=1))
values(CpGs) <- as.data.frame(tab)[,-c(1:2)]
# fix for sample names that start with a number
names(values(CpGs)) <- colnames(tab)[-c(1:2)]
seqlengths(CpGs) <- seqlengths(build)[seqlevels(CpGs)]
rm(tab)

# Per-sample PMDs, UMRs and LMRs using MethylSeekR
# output.dir <- "/home/phuluu/data/WGBS10X_new/Test_Prostate/bigTable/bw/MethylSeekR"
output.dir <- commandArgs(TRUE)[4]
setwd(output.dir)

# Only perform MethylSeekR analysis when a sample has this minimum mean coverage
# sample <- "LNCaP"
sample <- commandArgs(TRUE)[5]
sample.C <- paste0(sample, ".C")
sample.cov <- paste0(sample, ".cov")
minMeanCov <- 5
num.cores <- 4
if (mean(values(CpGs)[[sample.cov]])>=minMeanCov) {
    message("Running MethylSeekR on ", sample)
    #Graphs from analysis
    pdf(paste0(sample, ".pdf"), width=14)
    meth <- CpGs
    values(meth) <- values(meth)[c(sample.cov, sample.C)]
    names(values(meth)) <- c("T", "M")

    #remove SNPs
    if (exists("dbSNP")) meth <- removeSNPs(meth, dbSNP)

    #Find PMDs
    plotAlphaDistributionOneChr(m=meth, chr.sel="chr10", num.cores=num.cores)
    sLengths <- seqlengths(build)[seqlevels(meth)]
    PMD <- segmentPMDs(meth, chr.sel="chr10", seqLengths=sLengths, num.cores=num.cores)
    plotPMDSegmentation(m=meth, segs=PMD, minCover = minMeanCov)

    write.csv(calculateFDRs(meth, CpG5kb, PMDs=PMD, num.cores=num.cores)$FDRs, paste0(sample,".PMD.stats"))
    write.csv(calculateFDRs(meth, CpG5kb, num.cores=num.cores)$FDRs, paste0(sample,".stats"))

    PMD.UMRLMR <- segmentUMRsLMRs(m=meth, meth.cutoff=0.5, nCpG.cutoff=5, num.cores=num.cores, myGenomeSeq=build, seqLengths=seqlengths(build), PMDs=PMD)
    plotFinalSegmentation(m=meth, segs=PMD.UMRLMR, meth.cutoff=0.5, PMDs=PMD, minCover = minMeanCov)

    # Repeat without filtering PMDs
    UMRLMR <- segmentUMRsLMRs(m=meth, meth.cutoff=0.5, nCpG.cutoff=5, num.cores=num.cores, myGenomeSeq=build, seqLengths=seqlengths(build))
    plotFinalSegmentation(m=meth, segs=UMRLMR, meth.cutoff=0.5, minCover = minMeanCov)

    dev.off()

    # Export to bed/bigbed
    tmp <- list("PMD"=PMD[PMD$type=="PMD"],
                "UMR"=UMRLMR[UMRLMR$type=="UMR"],
                "LMR"=UMRLMR[UMRLMR$type=="LMR"],
            "PMD.UMR"=PMD.UMRLMR[PMD.UMRLMR$type=="UMR"],
            "PMD.LMR"=PMD.UMRLMR[PMD.UMRLMR$type=="LMR"])

    chrom.sizes <- data.frame(seqlevels(build), seqlengths(build))
    write.table(chrom.sizes, paste0(sample, ".chrom.sizes"), quote=FALSE, sep="\t", row.names=FALSE, col.names=FALSE)

    for (j in names(tmp)) {
        bed.file.name <- paste(sample, j, "bed", sep=".")
        export(tmp[[j]], bed.file.name, format="bed")
        # system(paste0("cut -f1,2,3 ", bed.file.name, " > tmp; ", bedToBigBed, " tmp ", sample, ".chrom.sizes ", gsub(".bed$", ".bb", bed.file.name), "; rm tmp"))
	system(paste0("cut -f1,2,3 ", bed.file.name, " > tmp; bedToBigBed tmp ", sample, ".chrom.sizes ", gsub(".bed$", ".bb", bed.file.name), "; rm tmp"))
    }
}else{
    # '.PMD.bed', '.UMR.bed', '.LMR.bed', '.PMD.LMR.bed', '.PMD.UMR.bed', '.PMD.stats'
    line <- paste0("This sample has coverage mean lower than ", sample)
    for(i in c('.PMD.bed', '.UMR.bed', '.LMR.bed', '.PMD.LMR.bed', '.PMD.UMR.bed', '.PMD.stats')){
        filename <- paste0(sample, i)
        write(line, file = filename)
    }
}

sessionInfo()
