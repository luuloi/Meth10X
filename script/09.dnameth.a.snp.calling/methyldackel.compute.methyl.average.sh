#!bin/bash -e
# usage: bash methyldackel.sh input output reference

# load module 
export MODULEPATH=/share/ClusterShare/Modules/modulefiles/noarch:/share/ClusterShare/Modules/modulefiles/centos6.2_x86_64:/share/ClusterShare/Modules/modulefiles/contrib:$MODULEPATH
source /etc/profile.d/modules.sh

# get paramaters
# $1=aligned/PrEC/PrEC.bam
input=$1
sample=$(basename $input| cut -d. -f1)
# $2=calls/PrEC
# $output=calls/PrEC.MD.meth.summarize.txt
output="$2/${sample}.MD.meth.summarize.txt"
# GENOME="/home/phuluu/methods/darlo/annotations/hg19/hg19.fa"
GENOME=$3
# # example
# awk 'BEGIN{sumC=0;sumcov=0}NR>1{sumC=sumC+$5; sumcov=sumcov+$5+$6}END{print "CG:\t"NR-1"\t"100*sumC/sumcov"%"}' /home/phuluu/data/WGBS10X_new/Test_Prostate/called/PrEC//PrEC.MD.strands_CpG.bedGraph

# $1=aligned/PrEC/PrEC.bam
LOGFILE="$2/${sample}.methyldackel.compute.meth.average.log"

# strands
echo `date`" *** Compute DNA methylation average with MethylDackel" > $LOGFILE
# from MD: chrom/start/end/ratio/C/T
# track type="bedGraph" description="/home/phuluu/data/WGBS10X_new/Test_Prostate/called/PrEC/PrEC.MD CpG merged methylation levels"
# chr1  540799  540801  0 0 1
# chr1  540807  540809  0 0 1
echo " - CpG strands" >> "$LOGFILE"
cmd="""
awk 'BEGIN{sumC=0;sumcov=0}NR>1{sumC=sumC+\$5; sumcov=sumcov+\$5+\$6}END{print \"CG:\t\"NR-1\"\t\"100*sumC/sumcov\"%\"}' ${2}/${sample}.MD.strands_CpG.bedGraph > $output
"""
echo $cmd >> "$LOGFILE"; eval $cmd 2>> "$LOGFILE"
echo -e `date`" - Finished CpG strands\n" >> "$LOGFILE"

echo " - CH strands" >> "$LOGFILE"
cmd="""
awk 'BEGIN{sumC=0;sumcov=0}NR>1{sumC=sumC+\$5; sumcov=sumcov+\$5+\$6}END{print \"CH:\t\"NR-1\"\t\"100*sumC/sumcov\"%\"}' ${2}/${sample}.MD.strands_CHG.bedGraph ${2}/${sample}.MD.strands_CHH.bedGraph >> $output
"""
echo $cmd >> "$LOGFILE"; eval $cmd 2>> "$LOGFILE"
echo -e `date`" - Finished CH strands\n" >> "$LOGFILE"
