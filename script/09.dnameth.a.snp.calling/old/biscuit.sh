#!/bin/bash -e
# usage: bash biscuit.sh input output reference

# load module
export MODULEPATH=/share/ClusterShare/Modules/modulefiles/noarch:/share/ClusterShare/Modules/modulefiles/centos6.2_x86_64:/share/ClusterShare/Modules/modulefiles/contrib:$MODULEPATH 
export PATH=/home/phuluu/bin:$PATH
source /etc/profile.d/modules.sh
module load phuluu/perl/5.24.1
export PERL5LIB=/share/ClusterShare/software/contrib/phuluu/vcftools/src/perl/:$PERL5LIB
module load gi/bedtools/2.22.0
module load gi/tabix/0.2.6
biscuit="/home/phuluu/methods/DNAmeth.calling.method.comparison/biscuit/biscuit"
vcf_stats="/share/ClusterShare/software/contrib/phuluu/vcftools/bin/vcf-stats"

# get paramaters
# $1=aligned/PrEC/PrEC.bam
input=$1
sample=$(basename $input| cut -d. -f1)
# $2=aligned/PrEC
output=$2
ref=$3
mkdir -p $output

LOGFILE="${output}/${sample}.biscuit.SNP.calling.log"
echo `date`" *** SNP calling with Biscuit" > $LOGFILE

# 5 hours
echo "- Pileup" >> $LOGFILE
echo """ $biscuit pileup -m 60 -b 20 -k 1 -t 100000 -r $ref -i $input -o "${output}/${sample}.BC.vcf" -q 8 -P 0.001 -Q 0.900 """ >> $LOGFILE
$biscuit pileup -m 60 -b 20 -k 1 -t 100000 -r $ref -i $input -o "${output}/${sample}.BC.vcf" -q 8 -P 0.001 -Q 0.900 2>> $LOGFILE
echo `date`" Finished pileup" >> $LOGFILE

# CpG
# chr1	61946	61948	1.000	1	CG	CG
# chr1	61953	61955	1.000	1	CG	CG
# chr1	62081	62083	0.000	4	CG	CG
# chr1	62095	62097	0.000	4	CG	CG
echo "- Convert vcf to bed: CpG" >> $LOGFILE 
echo """ $biscuit vcf2bed -k 1 -c -t cg "${output}/${sample}.BC.vcf"|awk '{printf \"%s\\t%s\\t%s\\t%4.0f\\t%4.0f\n\", \$1, \$2, \$2, \$4*\$5, \$5}' > "${output}/${sample}.BC.CpG.bed" """ >> $LOGFILE
$biscuit vcf2bed -k 1 -c -t cg "${output}/${sample}.BC.vcf"|awk '{printf "%s\t%s\t%s\t%4.0f\t%4.0f\n", $1, $2, $2, $4*$5, $5}' > "${output}/${sample}.BC.CpG.bed" 2>> $LOGFILE
echo `date`" Finished convert vcf to bed: CpG" >> $LOGFILE

# # CH
# # chr1	565507	565508	0.000	5	G	CHH
# # chr1	565508	565509	0.000	5	G	CHH
# # chr1	565511	565512	0.000	5	G	CHG
# echo "- CH">> $LOGFILE
# echo """ $biscuit vcf2bed -k 1 -c -t ch "${output}/${sample}.BC.vcf"|awk '{printf \"%s\\t%s\\t%s\\t%4.0f\\t%4.0f\n\", \$1, \$2, \$2, \$4*\$5, \$5, \$6, \$7}' > "${output}/${sample}.BC.CH.bed" """ >> $LOGFILE
# $biscuit vcf2bed -k 1 -c -t ch "${output}/${sample}.BC.vcf"|awk '{printf "%s\t%s\t%s\t%4.0f\t%4.0f\n", $1, $2, $2, $4*$5, $5, $6, $7}' > "${output}/${sample}.BC.CH.bed" 2>> $LOGFILE

# SNP
echo "- SNP" >> $LOGFILE
echo """ $biscuit vcf2bed -k 1 -c -t snp "${output}/${sample}.BC.vcf" > "${output}/${sample}.BC.snp.bed" """ >> $LOGFILE
$biscuit vcf2bed -k 1 -c -t snp "${output}/${sample}.BC.vcf" > "${output}/${sample}.BC.snp.bed" 2>> $LOGFILE
echo `date`" Finished convert vcf to bed: SNP" >> $LOGFILE

# filter SNP
# echo "- Filter SNP" >> $LOGFILE
# echo """ bedtools intersect -a "${output}/${sample}.BC.CpG.bed" -b "${output}/${sample}.BC.snp.bed" -v > "${output}/${sample}.BC.CpG.filter.out.snp.bed" """ >> $LOGFILE
# bedtools intersect -a "${output}/${sample}.BC.CpG.bed" -b "${output}/${sample}.BC.snp.bed" -v > "${output}/${sample}.BC.CpG.filter.out.snp.bed" 2>> $LOGFILE
# echo `date`" Finished filter out SNP" >> $LOGFILE

# convert SNP bed to vcf (so these vcfs of all samples can be merged into one file)
echo `date`"- Convert bed to vcf: SNP" >> $LOGFILE
# End of header: 
# #CHROM	POS	ID	REF	ALT	QUAL	FILTER	INFO	FORMAT	PrEC
grep -m 1 -B $(grep -m 1 -n "#CHROM" "${output}/${sample}.BC.vcf"|cut -d: -f1) "#CHROM" "${output}/${sample}.BC.vcf" > "${output}/${sample}.BC.snp.vcf"
cmd="""
bedtools intersect -a "${output}/${sample}.BC.vcf" -b "${output}/${sample}.BC.snp.bed" -wa >> "${output}/${sample}.BC.snp.vcf"
"""
echo $cmd >> "$LOGFILE"; eval $cmd 2>> "$LOGFILE"
cmd="""bgzip ${output}/${sample}.BC.snp.vcf"""
echo $cmd >> "$LOGFILE"; eval $cmd 2>> "$LOGFILE"

cmd="""tabix -f -p vcf ${output}/${sample}.BC.snp.vcf.gz"""
echo $cmd >> "$LOGFILE"; eval $cmd 2>> "$LOGFILE"

cmd="""$vcf_stats ${output}/${sample}.BC.snp.vcf.gz > ${output}/${sample}.BC.snp.vcf.gz.stats"""
echo $cmd >> "$LOGFILE"; eval $cmd 2>> "$LOGFILE"

echo "Convert Vcf-stats output to table format" >> $LOGFILE
cat <<<EOF  >> $LOGFILE
sed ':a;N;$!ba;s/\n//g' ${output}/${sample}.BC.snp.vcf.gz.stats| tr -d " "| egrep -oh "'snp'=>{.*},"| 
cut -d} -f1| cut -d{ -f2| tr "," "\n"| sed 's/=>/\t/'| sort -nrk 2,2 > ${output}/${sample}.BC.snp.vcf.gz.stats.tsv
EOF
sed ':a;N;$!ba;s/\n//g' "${output}/${sample}.BC.snp.vcf.gz.stats"| tr -d " "| egrep -oh "'snp'=>{.*},"| cut -d} -f1| cut -d{ -f2| tr "," "\n"| sed 's/=>/\t/'| sort -nrk 2,2 > "${output}/${sample}.BC.snp.vcf.gz.stats.tsv" 2>> $LOGFILE
echo -e `date`" Finished - Convert bed to vcf: SNP\n" >> $LOGFILE


# zip output file
echo `date`"- Zip output files" >> $LOGFILE
# bgzip "${output}/${sample}.BC.CH.bed";
cmd="""gzip ${output}/${sample}.BC.vcf"""
echo $cmd >> "$LOGFILE"; eval $cmd 2>> "$LOGFILE"

cmd="""gzip ${output}/${sample}.BC.CpG.bed"""
echo $cmd >> "$LOGFILE"; eval $cmd 2>> "$LOGFILE"

cmd="""gzip < ${output}/${sample}.BC.snp.bed > ${output}/${sample}.BC.snp.bed.gz"""
echo $cmd >> "$LOGFILE"; eval $cmd 2>> "$LOGFILE"
echo `date`" Zip output files" >> $LOGFILE

echo `date`" - Finished SNP calling with Biscuit" >> $LOGFILE



# # extract snp in vcf format from vcf whole genome
# module load gi/tabix/0.2.6
# bgzip /home/phuluu/data/WGBS10X_new/Test_Prostate/called/LNCaP/LNCaP.BC.vcf
# tabix -p vcf /home/phuluu/data/WGBS10X_new/Test_Prostate/called/LNCaP/LNCaP.BC.vcf.gz
# tabix -h /home/phuluu/data/WGBS10X_new/Test_Prostate/called/LNCaP/LNCaP.BC.vcf.gz -B /home/phuluu/data/WGBS10X_new/Test_Prostate/called/LNCaP/LNCaP.BC.snp.bed| grep -v lambda

