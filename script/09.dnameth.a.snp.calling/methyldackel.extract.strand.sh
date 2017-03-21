#!bin/bash -e
# usage: bash methyldackel.sh input output reference

# load module 
export MODULEPATH=/share/ClusterShare/Modules/modulefiles/noarch:/share/ClusterShare/Modules/modulefiles/centos6.2_x86_64:/share/ClusterShare/Modules/modulefiles/contrib:$MODULEPATH
source /etc/profile.d/modules.sh
module load phuluu/MethylDackel/0.2.0
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
mkdir -p $output

LOGFILE="${output}/${sample}.methyldackel.extract.strand.log"

# get trim option
# $MethylDackel extract $(cut -d: -f2 temp.txt) -q 60 -p 20 -d 1 -D 100000 --mergeContext 
# -o LNCaP Projects/WGBS10X_new/annotations/hg19/hg19.fa data/WGBS10X_new/Test_Prostate/merged/LNCaP/LNCaP.bam
# /home/phuluu/methods/DNAmeth.calling.method.comparison/MethylDackel/bin/MethylDackel extract \
# --OT 3,0,0,0 --OB 2,93,0,0 -q 60 -p 20 -d 1 -D 100000 --mergeContext \
# -o LNCaP Projects/WGBS10X_new/annotations/hg19/hg19.fa data/WGBS10X_new/Test_Prostate/merged/LNCaP/LNCaP.bam
trim=$(cut -d: -f2 ${input/.bam/.MD.bias.txt})

# strands
echo `date`" *** DNA methylation calling strands with MethylDackel" > $LOGFILE
echo -e """
MethylDackel extract $trim \n
                      -q 60 \n
                      -p 20 \n
                      -d 1 \n
                      -D 100000 \n
                      -o "${output}/${sample}.MD.strands" \n
                      --CHG \n
                      --CHH \n
                      $GENOME $input
""" >> $LOGFILE
# MethylDackel extract reference_genome.fa alignments.bam
# # trim: --nOT 1,1,1,1 --nOB 1,1,1,1 --nCTOT 1,1,1,1 --nCTOB 1,1,1,1
MethylDackel extract $trim \
                      -q 60 \
                      -p 20 \
                      -d 1 \
                      -D 100000 \
                      -o "${output}/${sample}.MD.strands" \
                      --CHG \
                      --CHH \
                      $GENOME $input 2>> $LOGFILE
echo `date`" Finished DNA methylation calling strands with MethylDackel" >> $LOGFILE
# convert format file
# from MD: chrom/start/end/ratio/C/T
# track type="bedGraph" description="/home/phuluu/data/WGBS10X_new/Test_Prostate/called/PrEC/PrEC.MD CpG merged methylation levels"
# chr1  540799  540801  0 0 1
# chr1  540807  540809  0 0 1
# to:
# chr     position  strand  MCF7.C  MCF7.cov
# chr1    10469     +       0       0
# chr1    10470     -       6       7
