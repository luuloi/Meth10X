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
# GSIZE="/share/ClusterShare/biodata/contrib/phuluu/bwa_meth/annotations/hg19/hg19.chrom.sizes.short"
GSIZE=${GENOME/.fa/.chrom.sizes.short}

minCov=1

mkdir -p $OUTPUT
LOGFILE="$OUTPUT/${sample}.CpGibias.and.compute.distribution.log"

echo " *** Compute CpG island bias and distribution " > "$LOGFILE"
echo `date`" - Started processing $1 on $HOSTNAME" >> "$LOGFILE"

echo " - Compute CpG methylation distribution" >> "$LOGFILE"
cmd="""
zcat $INPUT| egrep \"chr[0-9XYM]\"| awk -v minCov=$minCov 'NR>1{if(\$4>=minCov) printf \"%s\t%s\t%s\t%.4f\n\", \$1, \$2, \$2, \$3/\$4}' > "$OUTPUT/${sample}.methratio.bed"
""" 
echo $cmd >> "$LOGFILE"; eval $cmd 2>> "$LOGFILE"

cmd="""
zcat $INPUT| egrep \"chr[0-9XYM]\"| awk '{OFS=\"\t\"}{print \$1, \$2, \$2, \$4}'| tee "$OUTPUT/${sample}.cov.bed"| awk '{print \$1,\"\t\",\$4}' > "$OUTPUT/${sample}.CpG.coverage.per.chrom.tsv"
""" 
echo $cmd >> "$LOGFILE"; eval $cmd 2>> "$LOGFILE"

echo `date`" - Smooth methylation ratio CpG and compute methylation distribution" >> "$LOGFILE"
# single CpG
cmd="""
cut -f4 "$OUTPUT/${sample}.methratio.bed"| sort| uniq -c| awk -v sample=$sample '{OFS=\"\t\"}{print sample,\$2,\$1}' > "$OUTPUT/${sample}.distribution.Single_CpGs.tsv"
""" 
echo $cmd >> "$LOGFILE"; eval $cmd 2>> "$LOGFILE"

# 100bp
cmd="""
bedtools intersect -a <(bedtools makewindows -g $GSIZE -w 100) -b "$OUTPUT/${sample}.methratio.bed" -wa -wb| \
bedtools groupby -i - -g 1,2,3 -c 7 -o mean| awk '{ printf \"%.4f\n\", \$4}'| sort| uniq -c| awk -v sample=$sample '{OFS=\"\t\"}{print sample,\$2,\$1}' > "$OUTPUT/${sample}.distribution.100bp.tsv"
""" 
echo $cmd >> "$LOGFILE"; eval $cmd 2>> "$LOGFILE"

# 1kb
cmd="""
bedtools intersect -a <(bedtools makewindows -g $GSIZE -w 1000) -b "$OUTPUT/${sample}.methratio.bed" -wa -wb| \
bedtools groupby -i - -g 1,2,3 -c 7 -o mean| awk '{ printf \"%.4f\n\", \$4}'| sort| uniq -c| awk -v sample=$sample '{OFS=\"\t\"}{print sample,\$2,\$1}' > "$OUTPUT/${sample}.distribution.1kb.tsv"
""" 
echo $cmd >> "$LOGFILE"; eval $cmd 2>> "$LOGFILE"

# 10kb
cmd="""
bedtools intersect -a <(bedtools makewindows -g $GSIZE -w 10000) -b "$OUTPUT/${sample}.methratio.bed" -wa -wb| \
bedtools groupby -i - -g 1,2,3 -c 7 -o mean| awk '{ printf \"%.4f\n\", \$4}'| sort| uniq -c| awk -v sample=$sample '{OFS=\"\t\"}{print sample,\$2,\$1}' > "$OUTPUT/${sample}.distribution.10kb.tsv"
""" 
echo $cmd >> "$LOGFILE"; eval $cmd 2>> "$LOGFILE"

# 100kb
cmd="""
bedtools intersect -a <(bedtools makewindows -g $GSIZE -w 100000) -b "$OUTPUT/${sample}.methratio.bed" -wa -wb| \
bedtools groupby -i - -g 1,2,3 -c 7 -o mean| awk '{ printf \"%.4f\n\", \$4}'| sort| uniq -c| awk -v sample=$sample '{OFS=\"\t\"}{print sample,\$2,\$1}' > "$OUTPUT/${sample}.distribution.100kb.tsv"
""" 
echo $cmd >> "$LOGFILE"; eval $cmd 2>> "$LOGFILE"

# CpG islands
cmd="""
bedtools intersect -a $CpGislands -b "$OUTPUT/${sample}.methratio.bed" -wa -wb| \
bedtools groupby -i - -g 1,2,3 -c 10 -o mean| awk '{ printf \"%.4f\n\", \$4}'| sort| uniq -c| \
awk -v sample=$sample '{OFS=\"\t\"}{print sample,\$2,\$1}' > "$OUTPUT/${sample}.distribution.CpGislands.tsv"
""" 
echo $cmd >> "$LOGFILE"; eval $cmd 2>> "$LOGFILE"

# CpG shores
cmd="""
bedtools intersect -a $CpGshores -b "$OUTPUT/${sample}.methratio.bed" -wa -wb| \
bedtools groupby -i - -g 1,2,3 -c 10 -o mean| awk '{ printf \"%.4f\n\", \$4}'| sort| uniq -c| \
awk -v sample=$sample '{OFS=\"\t\"}{print sample,\$2,\$1}' > "$OUTPUT/${sample}.distribution.CpGshores.tsv"
""" 
echo $cmd >> "$LOGFILE"; eval $cmd 2>> "$LOGFILE"

# others
cmd="""
bedtools intersect -a $others -b "$OUTPUT/${sample}.methratio.bed" -wa -wb| \
bedtools groupby -i - -g 1,2,3 -c 7 -o mean| awk '{ printf \"%.4f\n\", \$4}'| sort| uniq -c| \
awk -v sample=$sample '{OFS=\"\t\"}{print sample,\$2,\$1}' > "$OUTPUT/${sample}.distribution.others.tsv"
""" 
echo $cmd >> "$LOGFILE"; eval $cmd 2>> "$LOGFILE"

### Bias
echo `date`" - Compute CpG islands/Shores bias" >> "$LOGFILE"
echo -e "Regions\tCoverage" > "$OUTPUT/${sample}.CpG.bias.plot.tsv"

echo " - CpGislands" >> $LOGFILE
cmd="""
CpGislands_cov=\$(bedtools intersect -a $CpGislands -b $OUTPUT/${sample}.cov.bed -wa -wb| awk '{OFS=\"\t\"}{print \"CpGislands\", \$10}'| tee -a "$OUTPUT/${sample}.CpG.bias.plot.tsv"| awk '{sum+=\$2}END{print sum/NR}');
"""
echo $cmd >> "$LOGFILE"; eval $cmd 2>> "$LOGFILE"

echo " - CpGshores" >> $LOGFILE
cmd="""
CpGshores_cov=\$(bedtools intersect -a $CpGshores -b $OUTPUT/${sample}.cov.bed -wa -wb| awk '{OFS=\"\t\"}{print \"CpGshores\", \$10}'| tee -a "$OUTPUT/${sample}.CpG.bias.plot.tsv"| awk '{sum+=\$2}END{print sum/NR}');
"""
echo $cmd >> "$LOGFILE"; eval $cmd 2>> "$LOGFILE"

echo " - Others" >> $LOGFILE
cmd="""
others_cov=\$(bedtools intersect -a $others -b $OUTPUT/${sample}.cov.bed -wa -wb| awk '{OFS=\"\t\"}{print \"Others\", \$7}'| tee -a "$OUTPUT/${sample}.CpG.bias.plot.tsv"| awk '{sum+=\$2}END{print sum/NR}');
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

# clean
cmd="""
rm "$OUTPUT/${sample}.methratio.bed";
rm "$OUTPUT/${sample}.cov.bed"
""" 
echo $cmd >> "$LOGFILE"; eval $cmd 2>> "$LOGFILE"
echo `date`" - Finished processing $1" >> "$LOGFILE"

