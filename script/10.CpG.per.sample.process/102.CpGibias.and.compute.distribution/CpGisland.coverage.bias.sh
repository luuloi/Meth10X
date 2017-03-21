#!bin/bash

# usage: bash CpGibias.and.compute.distribution.sh input output CpGislands CpGshores others GSIZE

# load module 
export MODULEPATH=/share/ClusterShare/Modules/modulefiles/noarch:/share/ClusterShare/Modules/modulefiles/centos6.2_x86_64:/share/ClusterShare/Modules/modulefiles/contrib:$MODULEPATH 
export PATH=/home/phuluu/bin:$PATH
source /etc/profile.d/modules.sh
module load gi/bedtools/2.22.0

# INPUT="/home/darloluu/tmp/Test_Prostate/called/LNCaP/LNCaP.MD_CpG.tsv.gz"
# chr	position	LNCaP.C		LNCaP.cov
# chr1	10468		0			0
# chr1	10470		0			0

INPUT=$1
# OUTPUT="/home/darloluu/tmp/Test_Prostate/bigTables/QC/distributions"
OUTPUT=$2
# sample="PrEC"
sample=$(basename $INPUT| cut -d. -f1)
# GENOME="/share/ClusterShare/biodata/contrib/phuluu/bwa_meth/annotations/hg19/hg19.fa"
GENOME=$3
# CpGislands="/share/ClusterShare/biodata/contrib/phuluu/bwa_meth/annotations/hg19/hg19.CpGislands.bed"
CpGislands=${GENOME/.fa/.CpGislands.bed}
# CpGshores="/share/ClusterShare/biodata/contrib/phuluu/bwa_meth/annotations/hg19/hg19.CpGshores.bed"
CpGshores=${GENOME/.fa/.CpGshores.bed}
# others="/share/ClusterShare/biodata/contrib/phuluu/bwa_meth/annotations/hg19/hg19.others.bed"
others=${GENOME/.fa/.others.bed}

mkdir -p $OUTPUT
LOGFILE="$OUTPUT/${sample}.CpGisland.coverage.bias.log"


### Bias
echo `date`" - Compute CpG islands/Shores bias" > "$LOGFILE"
echo -e "Regions\tCoverage" > "$OUTPUT/${sample}.CpG.bias.plot.tsv"

echo " - CpGislands" >> $LOGFILE
cmd="""
CpGislands_cov=\$(bedtools intersect -a $CpGislands -b $OUTPUT/${sample}.cov.bed -wa -wb| awk '{OFS=\"\t\"}{print \"CpGislands\", \$10}'| tee -a "$OUTPUT/${sample}.CpG.bias.plot.tsv.tmp"| awk '{sum+=\$2}END{print sum/NR}');
"""
echo $cmd >> "$LOGFILE"; eval $cmd 2>> "$LOGFILE"

echo " - CpGshores" >> $LOGFILE
cmd="""
CpGshores_cov=\$(bedtools intersect -a $CpGshores -b $OUTPUT/${sample}.cov.bed -wa -wb| awk '{OFS=\"\t\"}{print \"CpGshores\", \$10}'| tee -a "$OUTPUT/${sample}.CpG.bias.plot.tsv.tmp"| awk '{sum+=\$2}END{print sum/NR}');
"""
echo $cmd >> "$LOGFILE"; eval $cmd 2>> "$LOGFILE"

echo " - Others" >> $LOGFILE
cmd="""
others_cov=\$(bedtools intersect -a $others -b $OUTPUT/${sample}.cov.bed -wa -wb| awk '{OFS=\"\t\"}{print \"Others\", \$7}'| tee -a "$OUTPUT/${sample}.CpG.bias.plot.tsv.tmp"| awk '{sum+=\$2}END{print sum/NR}');
"""
echo $cmd >> "$LOGFILE"; eval $cmd 2>> "$LOGFILE"

echo " - CpGislands bias" >> $LOGFILE
cmd="""
CpGislands_bias=\$(bc -l <<< $CpGislands_cov/$others_cov);
"""
echo $cmd >> "$LOGFILE"; eval $cmd 2>> "$LOGFILE"

echo " - CpGshores bias" >> $LOGFILE
cmd="""
CpGshores_bias=\$(bc -l <<< $CpGshores_cov/$others_cov);
"""
echo $cmd >> "$LOGFILE"; eval $cmd 2>> "$LOGFILE"

echo " - Make tsv file" >> $LOGFILE
cmd="""
echo -e \"$sample\t${CpGislands_cov}\t${CpGshores_cov}\t${others_cov}\t${CpGislands_bias}\t${CpGshores_bias}\" > "$OUTPUT/${sample}.CpG_bias.tsv"
""" 
echo $cmd >> "$LOGFILE"; eval $cmd 2>> "$LOGFILE"

echo " - Count CpG coverage in CpG islands/shores/others" >> "$LOGFILE"
echo -e "Regions\tCoverage\tFrequency" > "$OUTPUT/${sample}.CpG.bias.plot.tsv"
cmd="""
sort -k1,1 -k2,2n "$OUTPUT/${sample}.CpG.bias.plot.tsv.tmp"| uniq -c| awk '{OFS=\"\t\"}{print \$2,\$3,\$1}' >> "$OUTPUT/${sample}.CpG.bias.plot.tsv"
"""
echo $cmd >> "$LOGFILE"; eval $cmd 2>> "$LOGFILE"

cmd="""
rm "$OUTPUT/${sample}.CpG.bias.plot.tsv.tmp"
"""
echo $cmd >> "$LOGFILE"; eval $cmd 2>> "$LOGFILE"

echo `date`" - Finished processing $1" >> "$LOGFILE"


