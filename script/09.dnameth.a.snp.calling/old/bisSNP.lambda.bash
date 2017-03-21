sample="PrEC"
GENOME="/home/darloluu/methods/darlo/annotations/hg19/hg19.fa"
CHROM="lambda"
refer="$(dirname $GENOME)/${CHROM}.tsv"
OUTPUT="."
output1="$OUTPUT/${sample}.${CHROM}.CpG.strand.tsv"
cd ~/tmp/Test_Prostate/called/$sample
bisSNP=${sample}.chrlambda.${sample}.meth.dedup.bed
echo $output1
module load gi/bedtools/2.22.0
bedtools intersect -a <(awk '{OFS="\t"}{$3=$3-1; print}' $refer) -b $bisSNP -loj -f 1| \
awk '{OFS="\t"}{if($7=="."){$11=0;$12=0};print $1,$3+1,$6,$11,$11+$12}' > $output1
head $output1
