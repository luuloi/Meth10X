#!bin/bash

# usage: bash qc.per.sample.sh input output

# load module 
export MODULEPATH=/share/ClusterShare/Modules/modulefiles/noarch:/share/ClusterShare/Modules/modulefiles/centos6.2_x86_64:/share/ClusterShare/Modules/modulefiles/contrib:$MODULEPATH 
export PATH=/home/phuluu/bin:$PATH
source /etc/profile.d/modules.sh
module load phuluu/R/3.1.2

BASEDIR=$(dirname $0)
# INPUT="/home/darloluu/tmp/Test_Prostate/called/LNCaP/LNCaP.MD_CpG.tsv.gz"
# chr	positions	positione	LNCaP.C		LNCaP.cov
# chr1	10468		10470		0		0
# chr1	10470		10472		0		0
INPUT=$1
# OUTPUT="/home/darloluu/tmp/Test_Prostate/bigTables/QC/per-sample"
OUTPUT=$2
# sample="PrEC"
sample=$(basename $INPUT| cut -d. -f1)
# CpG_coverage_per_chrom
CpG_coverage_per_chrom="${OUTPUT/per-sample/distributions}/${sample}.CpG.coverage.per.chrom.tsv"

mkdir -p $OUTPUT
LOGFILE="$OUTPUT/${sample}.plot.coverage.per.chromosome.and.sample.log"

echo " *** Plot DNAmeth distribution per chromosome" > "$LOGFILE"
echo `date`" - Started processing $1 on $HOSTNAME" >> "$LOGFILE"

# plot: CpG coverage for each chromosome, whole genome CpG coverage, plot CpG bias boxplot
echo " - Plot coverage for each chromosome, whole genome CpG coverage, plot CpG bias boxplot" >> "$LOGFILE"
input_CpG_bias="$(dirname $OUTPUT)/distributions"
cmd="""
Rscript "$BASEDIR/plot.coverage.per.chromosome.and.sample.r" "$CpG_coverage_per_chrom" "$OUTPUT/${sample}.CpG.coverage.tsv" "$input_CpG_bias/${sample}.CpG.bias.plot.tsv" "$sample"
"""
echo $cmd >> "$LOGFILE"; eval $cmd >> "$LOGFILE" 2>&1

echo "Clean up" >> "$LOGFILE"
cmd=""" rm ${INPUT/.gz/} """
echo $cmd >> "$LOGFILE"; eval $cmd 2>> "$LOGFILE"
echo `date`" - Finished processing $1" >> $LOGFILE

