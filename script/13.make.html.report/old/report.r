```{r SNP, echo=FALSE, results='asis'}
samples <- c("LNCaP", "PrEC", "PrEC_1")

tb1 <- sapply(samples, function(x){tb<-read.table(paste0("called/",x,"/",x,".snp.filter.summary.txt"),sep="=");paste0(gsub(" ","",tb[2,"V2"]),"(",gsub(" ","",tb[3,"V2"]),")")})
tb1 <- as.data.frame(tb1)
colnames(tb1) <- "CpG.overlap.SNP"

tb2 <- sapply(samples, function(x){tb<-read.table(paste0("called/",x,"/",x,".BC.snp.vcf.gz.stats.tsv"));s<-sum(tb$V2);tb$V2<-paste0("(",round(100*tb$V2/s,2),"%)");c(s,do.call(paste,tb[1:5,]))})
tb2 <- as.data.frame(t(tb2))
colnames(tb2) <- c("Total.SNP", "Top.1", "Top.2", "Top.3", "Top.4", "Top.5")

tb <- data.frame(cbind(tb1,tb2))
tab <- xtable(tb)
print(tab, type="html")
```
