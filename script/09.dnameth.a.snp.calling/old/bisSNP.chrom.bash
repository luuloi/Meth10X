#!/bin/bash -e

if [ $# -lt 3 ]
then
  echo "Usage: `basename $0` {Sample} {Genome} {No of 5' Bases to trim}"
  exit 1
fi

export MODULEPATH=/share/ClusterShare/Modules/modulefiles/noarch:/share/ClusterShare/Modules/modulefiles/centos6.2_x86_64:/share/ClusterShare/Modules/modulefiles/contrib:$MODULEPATH
export PATH=/home/darloluu/bin:$PATH
source /etc/profile.d/modules.sh

module unload gi/java/jdk1.8.0_25
module load phuluu/python/2.7.8
module load gi/java/jdk1.7.0_45
module load aarsta/bwa/0.7.9a

BASEPATH=$(dirname $0)
JAVA="java -Djava.io.tmpdir=/tmp"
bam=$1
OUTPUT=$2
sample=$(basename $OUTPUT)
# GENOME="/home/darloluu/methods/darlo/annotations/hg19/hg19.fa"
GENOME=$3
# "1,1"
trim=$4
CHROM=${5/chrlambda/lambda}
LOGFILE="$OUTPUT/${sample}.${CHROM}.bissnp.log"

echo "bisSNP.sh" > "$LOGFILE"
echo `date`" - Starting bissnp on $1 on $HOSTNAME" >> "$LOGFILE"
echo """bwameth.py tabulate --bissnp $BASEPATH/BisSNP-0.82.2.jar --trim $trim --map-q 60 --threads 32 --prefix $OUTPUT/$sample.bissnp --reference $GENOME --region $CHROM --context all $bam """ >> "$LOGFILE" 
bwameth.py tabulate \
--trim "$trim" \
--bissnp $BASEPATH/BisSNP-0.82.2.jar \
--map-q 60 \
--threads 16 \
--prefix "$OUTPUT/$sample" \
--reference "$GENOME" \
--region $CHROM \
--context all \
$bam 1>&2 >> "$LOGFILE"
echo `date`" - Finished bisSNP" >> "$LOGFILE"

echo `date`" - Starting process bissnp output" >> "$LOGFILE"
module load gi/bedtools/2.22.0

# refer=/home/darloluu/methods/darlo/annotations/hg19/hg19.CpG.WGBS/hg19.CpG.WGBS.chr21.tsv
refer_name=$(basename $GENOME| cut -d. -f1)

# if chrom is lambda
if [[ $CHROM = "lambda" ]]; then
	# input
	# intersect these CpG and CpH chromosomes with bisSNP output
	# bisSNP=/home/darloluu/tmp/Test_Prostate/called/LNCaP/LNCaP.chr21.LNCaP.meth.bed
	bisSNPraw="$OUTPUT/${sample}.${CHROM}.${sample}.meth.bed"
	bisSNP="$OUTPUT/${sample}.chr${CHROM}.${sample}.meth.dedup.bed"
	sort -k2,2n $bisSNPraw| uniq > $bisSNP
	refer="$(dirname $GENOME)/${CHROM}.tsv"
	# output1=/home/darloluu/tmp/Test_Prostate/called/LNCaP/LNCaP.chr21.CpG.bedtools.strand.tsv
	output1="$OUTPUT/${sample}.${CHROM}.strand.tsv"
	echo "*** Create tsv for lambda CpG specific strands" >> "$LOGFILE"
	nrow0=$(wc -l $refer| awk '{print $1}')
	echo """bedtools intersect -a <(awk '{OFS=\"\t\"}{\$3=\$3-1; print}' $refer) -b $bisSNP -loj -f 1| 
	        awk '{OFS=\"\t\"}{if(\$7==\".\"){\$11=0;\$12=0};print \$1,\$3+1,\$6,\$11,\$11+\$12}' > $output1 """ >> "$LOGFILE"
	bedtools intersect -a <(awk '{OFS="\t"}{$3=$3-1; print}' $refer) -b $bisSNP -loj -f 1| \
	awk '{OFS="\t"}{if($7=="."){$11=0;$12=0};print $1,$3+1,$6,$11,$11+$12}' > $output1
	nrow1=$(wc -l $output1| awk '{print $1}')
	# check duplication
	if [[ $nrow1 -gt $nrow0 ]]; then
		echo "Duplication in lambda CpG specific strand" >> "$LOGFILE"; 
		exit;
	fi
	# change name
	mv $bisSNPraw "$OUTPUT/${sample}.chr${CHROM}.${sample}.meth.bed"
	mv "$OUTPUT/${sample}.${CHROM}.meth.vcf" "$OUTPUT/${sample}.chr${CHROM}.meth.vcf"
	mv "$OUTPUT/${sample}.${CHROM}.snp.vcf" "$OUTPUT/${sample}.chr${CHROM}.snp.vcf"
else
	for i in CpG CpH;
	do
		# input
		# bisSNP=/home/darloluu/tmp/Test_Prostate/called/LNCaP/LNCaP.chr21.LNCaP.meth.bed
		bisSNPraw="$OUTPUT/${sample}.${CHROM}.${sample}.meth.bed"
		bisSNP="$OUTPUT/${sample}.${CHROM}.${sample}.meth.dedup.bed"
		sort -k2,2n $bisSNPraw| uniq > $bisSNP
		refer="$(dirname $GENOME)/${refer_name}.${i}.WGBS/${refer_name}.${i}.WGBS.${CHROM}.tsv"
		# output1=/home/darloluu/tmp/Test_Prostate/called/LNCaP/LNCaP.chr21.CpG.bedtools.strand.tsv
		output1="$OUTPUT/${sample}.${CHROM}.${i}.bedtools.strand.tsv"
		echo "*** Create tsv for $i specific strands" >> "$LOGFILE"
		nrow0=$(wc -l $refer| awk '{print $1}')
		echo """bedtools intersect -a <(awk '{OFS=\"\t\"}{\$3=\$3-1; print}' $refer) -b $bisSNP -loj -f 1| 
		        awk '{OFS=\"\t\"}{if(\$7==\".\"){\$11=0;\$12=0};print \$1,\$3+1,\$6,\$11,\$11+\$12}' > $output1 """ >> "$LOGFILE"
		bedtools intersect -a <(awk '{OFS="\t"}{$3=$3-1; print}' $refer) -b $bisSNP -loj -f 1| \
		awk '{OFS="\t"}{if($7=="."){$11=0;$12=0};print $1,$3+1,$6,$11,$11+$12}' > $output1
		nrow1=$(wc -l $output1| awk '{print $1}')
		# check duplication
		if [[ $nrow1 -gt $nrow0 ]]; then
			echo "Duplication in $i specific strand" >> "$LOGFILE"; 
			exit;
		fi
		if [[ $i = "CpG" ]]; then
			echo "*** Merge both $i specific strands to one" >> "$LOGFILE"
			# output2=/home/darloluu/tmp/Test_Prostate/called/LNCaP/LNCaP.chr21.CpG.bedtools.tsv
			output2="$OUTPUT/${sample}.${CHROM}.${i}.bedtools.tsv"
			echo """awk '{OFS=\"\t\"}{if(\$3==\"-\"){print \$1,\$2-1,\$2-1,\$4,\$5,\$3}else{print \$1,\$2,\$2,\$4,\$5,\$3}}' $output1| 
		        	bedtools merge -i - -d -1 -c 4,5 -o sum| awk '{print \$1,\$2+1,\$4,\$5}' > $output2 """ >> "$LOGFILE"
			awk '{OFS="\t"}{if($3=="-"){print $1,$2-1,$2-1,$4,$5,$3}else{print $1,$2,$2,$4,$5,$3}}' $output1| \
			bedtools merge -i - -d -1 -c 4,5 -o sum| awk '{OFS="\t"}{print $1,$2+1,$4,$5}' > $output2
			nrow2=$(wc -l $output2| awk '{print 2*$1}')
			# check duplication
			if [[ $nrow2 -gt $nrow0 ]]; then
				echo "Duplication in merge $i strand" >> "$LOGFILE";
				exit;
			fi
		fi
	done
fi

echo `date`" - Finished process bissnp output" >> "$LOGFILE"
