#!bin/bash -e
# usage: bash methyldackel.sh input output reference

# load module 
export MODULEPATH=/share/ClusterShare/Modules/modulefiles/noarch:/share/ClusterShare/Modules/modulefiles/centos6.2_x86_64:/share/ClusterShare/Modules/modulefiles/contrib:$MODULEPATH 
export PATH=/home/phuluu/bin:$PATH
source /etc/profile.d/modules.sh
MethylDackel="/home/phuluu/methods/DNAmeth.calling.method.comparison/MethylDackel/bin/MethylDackel"
BASEDIR=`readlink -f "${0%/*}"`


# get paramaters
# $1=aligned/PrEC/PrEC.bam
input=$1
sample=$(basename $input| cut -d. -f1)
# $2=calls/PrEC
output=$2
# GENOME="/home/phuluu/methods/darlo/annotations/hg19/hg19.fa"
GENOME=$3
# # example
# input="/home/phuluu/data/WGBS10X_new/Test_Prostate/merged/PrEC/PrEC.bam"
# sample="PrEC"
# output="/home/phuluu/data/WGBS10X_new/Test_Prostate/called/PrEC/"
# GENOME="/home/phuluu/Projects/WGBS10X_new/V02/annotations/hg19/hg19.fa"


# convert format file
# from MD: chrom/start/end/ratio/C/T
# track type="bedGraph" description="/home/phuluu/data/WGBS10X_new/Test_Prostate/called/PrEC/PrEC.MD CpG merged methylation levels"
# chr1  540799  540801  0 0 1
# chr1  540807  540809  0 0 1
# to:
# merg context 
# chr position LNCaP.C   LNCaP.cov
# chr1  10469    0       0
# chr1  10471    0       0

LOGFILE="${output}/${sample}.methyldackel.CpG_merge.make.full.frame.log"

echo `date`" *** Convert merged context CpG bedGraph to bed" > $LOGFILE

# echo -e "#chr\tposition\t${sample}.C\t${sample}.cov" > "${output}/${sample}.MD_CpG.tsv"
# echo " - CpG" >> $LOGFILE
# cmd="""
# bedtools intersect -a ${GENOME/.fa/.CpG.bed} -b ${output}/${sample}.MD_CpG.bedGraph -loj| grep -v lambda| awk '{OFS=\"\t\"}{if(\$8==-1){\$8=\$9=0}; print \$1,\$3-1,\$8,\$8+\$9}' >> ${output}/${sample}.MD_CpG.tsv
# """
# echo $cmd >> "$LOGFILE"; eval $cmd 2>> "$LOGFILE"; echo -e `date`" Finished - merge context CpG\n" >> $LOGFILE

# example
# chr position LNCaP.C   LNCaP.cov
# chr1  10469    0       0
# chr1  10471    0       0
# python methydackel.CpG_strand.py 	sample_CpG 	g_CpG 	o_CpG	 sample
cmd="""
python $BASEDIR/methyldackel.CpG_merge.py ${output}/${sample}.MD_CpG.bedGraph ${GENOME/.fa/.CpG.bed} ${output}/${sample}.MD_CpG.tsv $sample
"""
echo $cmd >> "$LOGFILE"; eval $cmd 2>> "$LOGFILE"; echo -e `date`" Finished - CpG merg\n" >> $LOGFILE

echo "*** Zip output file"  >> $LOGFILE
cmd="""
gzip < ${output}/${sample}.MD_CpG.tsv > ${output}/${sample}.MD_CpG.tsv.gz;
"""
echo $cmd >> "$LOGFILE"; eval $cmd 2>> "$LOGFILE"; echo -e `date`" Zip output\n" >> $LOGFILE
