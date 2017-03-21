qrsh -pe smp 8 -l h_vmem=1000G
module load phuluu/R/3.1.2
cd /home/phuluu/methods/darlo/annotations/hg19
Rscript -e "library(rtracklayer); load('hg19.WGBS.Rdata'); export(CpG, '/home/phuluu/data/hg19.CpG.strands.bed', format='bed'); export(CpH, '/home/phuluu/data/hg19.CpHs.bed', format='bed')"
awk '{OFS="\t"}{if($6=="+") print $1,$3,$3}' hg19.CpG.strands.bed > hg19.CpG.bed
