#!/bin/bash -e

BASEDIR=$(dirname $0)
INPUT=$1
OUTPUT=$2
# "called/LNCaP"
sample=$(basename $INPUT)

METHvcf=""
METHbed=""
SNPs=""
STRANDCpG=""
STRANDCpH=""
MERGEDCpG=""

LOGFILE="${OUTPUT}/${sample}.merg.bissnp.chrom.log"
echo "merge.bisSNP.chrom.sh" > "$LOGFILE"
echo `date`" - Starting merge bissnp chrom to whole genome on $1 with $HOSTNAME" >> "$LOGFILE"

# for i in 22 Y;
for i in $(seq 1 22) M X Y;
do 
	if [[ -f "${INPUT}/${sample}.chr${i}.meth.vcf" ]]; then
		METHvcf="$METHvcf ${INPUT}/${sample}.chr${i}.meth.vcf";
	else
		echo "${INPUT}/${sample}.chr${i}.meth.vcf does not exist!"  >> "$LOGFILE";
		exit;	
	fi
	
	if [[ -f "${INPUT}/${sample}.chr${i}.${sample}.meth.bed" ]]; then
		METHbed="$METHbed ${INPUT}/${sample}.chr${i}.${sample}.meth.bed";
	else
		echo "${INPUT}/${sample}.chr${i}.${sample}.meth.bed does not exist!"  >> "$LOGFILE";
		exit;	
	fi

	if [[ -f "${INPUT}/${sample}.chr${i}.snp.vcf" ]]; then
		SNPs="$SNPs ${INPUT}/${sample}.chr${i}.snp.vcf";
	else
		echo "${INPUT}/${sample}.chr${i}.snp.vcf does not exist!"  >> "$LOGFILE";
		exit;	
	fi
	
	if [[ -f "${INPUT}/${sample}.chr${i}.CpG.bedtools.strand.tsv" ]]; then
		STRANDCpG="$STRANDCpG ${INPUT}/${sample}.chr${i}.CpG.bedtools.strand.tsv"
	else
		echo "${INPUT}/${sample}.chr${i}.CpG.bedtools.strand.tsv does not exist!"  >> "$LOGFILE";
		exit;	
	fi

	if [[ -f "${INPUT}/${sample}.chr${i}.CpH.bedtools.strand.tsv" ]]; then
		STRANDCpH="$STRANDCpH ${INPUT}/${sample}.chr${i}.CpH.bedtools.strand.tsv"
	else
		echo "${INPUT}/${sample}.chr${i}.CpH.bedtools.strand.tsv does not exist!"  >> "$LOGFILE";
		exit;	
	fi
	
	if [[ -f "${INPUT}/${sample}.chr${i}.CpG.bedtools.tsv" ]]; then
		MERGEDCpG="$MERGEDCpG ${INPUT}/${sample}.chr${i}.CpG.bedtools.tsv"
	else
		echo "${INPUT}/${sample}.chr${i}.CpG.bedtools.tsv does not exist!"  >> "$LOGFILE";
		exit;	
	fi
done
 
echo $METHvcf  >> "$LOGFILE"
cat $METHvcf > "${INPUT}/${sample}.bissnp.meth.vcf"
gzip -f "${INPUT}/${sample}.bissnp.meth.vcf"

echo $METHbed  >> "$LOGFILE"
cat $METHbed > "${INPUT}/${sample}.bissnp.${sample}.meth.bed"
gzip -f "${INPUT}/${sample}.bissnp.${sample}.meth.bed"

echo $SNPs >> "$LOGFILE"
cat $SNPs > "${INPUT}/${sample}.bissnp.snp.vcf"
gzip -f "${INPUT}/${sample}.bissnp.snp.vcf"

echo $STRANDCpG >> "$LOGFILE"
cat $STRANDCpG > "${INPUT}/${sample}.CpG.strand.tsv"
gzip -f "${INPUT}/${sample}.CpG.strand.tsv"

echo $STRANDCpH >> "$LOGFILE"
cat $STRANDCpH > "${INPUT}/${sample}.CpH.strand.tsv"
gzip -f "${INPUT}/${sample}.CpH.strand.tsv"

echo $MERGEDCpG >> "$LOGFILE"
cat $MERGEDCpG > "${INPUT}/${sample}.CpG.tsv"
gzip -f "${INPUT}/${sample}.CpG.tsv"

# zip lambda strand tsv
echo "$INPUT/${sample}.lambda.strand.tsv"  >> "$LOGFILE"
gzip -f "$INPUT/${sample}.lambda.strand.tsv"

# merge the summary
# /home/darloluu/tmp/Test_Prostate/called/LNCaP/LNCaP.chr*.meth.vcf.MethySummarizeList.txt
for i in `ls "${INPUT}/${sample}.chr*.meth.vcf.MethySummarizeList.txt"`; 
do 
echo $i;
# /home/darloluu/tmp/Test_Prostate/called/LNCaP/LNCaP.tmp.meth.vcf.MethySummarizeList.txt 
grep "CG\|CH" $i| sort| uniq >> "${INPUT}/${sample}.tmp.meth.vcf.MethySummarizeList.txt"
done

# compute the average CG and CH methylation for whole genome
Rscript $BASEDIR/merge.bissnp.summary.r "${INPUT}/${sample}.tmp.meth.vcf.MethySummarizeList.txt" "${INPUT}/${sample}.meth.vcf.MethySummarizeList.txt"

echo `date`" - Finished merge bissnp chrom to whole genome" >> "$LOGFILE"
