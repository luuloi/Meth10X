#!bin/bash

# usage: bash CpGibias.and.compute.distribution.sh input output

# load module 
export MODULEPATH=/share/ClusterShare/Modules/modulefiles/noarch:/share/ClusterShare/Modules/modulefiles/centos6.2_x86_64:/share/ClusterShare/Modules/modulefiles/contrib:$MODULEPATH 
source /etc/profile.d/modules.sh


# INPUT="/home/darloluu/tmp/Test_Prostate/called/LNCaP/LNCaP.MD_CpG.tsv.gz"
# chr	position	LNCaP.C		LNCaP.cov
# chr1	10468		0			0
# chr1	10470		0			0

INPUT=$1
# OUTPUT="/home/darloluu/tmp/Test_Prostate/bigTables/QC/distributions"
OUTPUT=$2
# sample="PrEC"
sample=$(basename $INPUT| cut -d. -f1)

minCov=1

mkdir -p $OUTPUT
LOGFILE="$OUTPUT/${sample}.compute.distribution.CpG.coverage.per.chrom.log"

echo " *** Compute CpG distribution " > "$LOGFILE"
echo `date`" - Started processing $1 on $HOSTNAME" >> "$LOGFILE"

cmd="""
zcat $INPUT| egrep \"chr[0-9XYM]\"| awk '{OFS=\"\t\"}{print \$1, \$2, \$2, \$4}' > "$OUTPUT/${sample}.cov.bed"
""" 
echo $cmd >> "$LOGFILE"; eval $cmd 2>> "$LOGFILE"


echo -e "Chrom\tCoverage\tFrequency" > "$OUTPUT/${sample}.CpG.coverage.per.chrom.tsv"
cmd="""
awk '{print \$1,\"\t\",\$4}' "$OUTPUT/${sample}.cov.bed"| sort -k1,1 -k2,2n| uniq -c| awk '{OFS=\"\t\"}{print \$2,\$3,\$1}' >> "$OUTPUT/${sample}.CpG.coverage.per.chrom.tsv"
""" 
echo $cmd >> "$LOGFILE"; eval $cmd 2>> "$LOGFILE"


echo `date`" - Finished processing $1" >> "$LOGFILE"

# example
# echo -e "Chrom\tCoverage\tFrequency" > CpG.coverage.per.chrom.tsv 
# cd ~/data/WGBS10X_new/Prostate_Brain/bigTable
# shuf -n 800 bigTable.tsv| awk '{OFS="\t"}{print $1,$10}'| sort -k1,1 -k2,2n| uniq -c| awk '{OFS="\t"}{print $2,$3,$1}' >> CpG.coverage.per.chrom.tsv
