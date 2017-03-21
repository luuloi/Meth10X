#!bin/bash -e
# usage: bash methyldackel.sh input output reference

# load module 
export MODULEPATH=/share/ClusterShare/Modules/modulefiles/noarch:/share/ClusterShare/Modules/modulefiles/centos6.2_x86_64:/share/ClusterShare/Modules/modulefiles/contrib:$MODULEPATH 
export PATH=/home/phuluu/bin:$PATH
source /etc/profile.d/modules.sh
MethylDackel="/home/phuluu/methods/DNAmeth.calling.method.comparison/MethylDackel/bin/MethylDackel"
module load gi/bedtools/2.22.0

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

LOGFILE="${output}/${sample}.methyldackel.meth.calling.log"

# strands
echo `date`" *** DNA methylation calling strands with MethylDackel" > $LOGFILE
echo -e """
$MethylDackel extract --nOT 1,1,1,1 --nOB 1,1,1,1 --nCTOT 1,1,1,1 --nCTOB 1,1,1,1 \n
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
$MethylDackel extract --nOT 1,1,1,1 --nOB 1,1,1,1 --nCTOT 1,1,1,1 --nCTOB 1,1,1,1 \
                      -q 60 \
                      -p 20 \
                      -d 1 \
                      -D 100000 \
                      -o "${output}/${sample}.MD.strands" \
                      --CHG \
                      --CHH \
                      $GENOME $input 2>> $LOGFILE
echo `date`" Finished DNA methylation calling strands with MethylDackel" >> $LOGFILE
### mergecontext CG only
echo `date`" *** DNA methylation calling merge context with MethylDackel" >> $LOGFILE
echo -e """
$MethylDackel extract --nOT 1,1,1,1 --nOB 1,1,1,1 --nCTOT 1,1,1,1 --nCTOB 1,1,1,1 \n
                      -q 60 \n
                      -p 20 \n
                      -d 1 \n
                      -D 100000 \n
                      --mergeContext \n
                      -o "${output}/${sample}.MD" \n
                      $GENOME $input
""" >> $LOGFILE
# MethylDackel extract reference_genome.fa alignments.bam
$MethylDackel extract --nOT 1,1,1,1 --nOB 1,1,1,1 --nCTOT 1,1,1,1 --nCTOB 1,1,1,1 \
                      -q 60 \
                      -p 20 \
                      -d 1 \
                      -D 100000 \
                      --mergeContext \
                      -o "${output}/${sample}.MD" \
                      $GENOME $input 2>> $LOGFILE
echo `date`" Finished DNA methylation calling merge context with MethylDackel" >> $LOGFILE
# convert format file
# from MD: chrom/start/end/ratio/C/T
# track type="bedGraph" description="/home/phuluu/data/WGBS10X_new/Test_Prostate/called/PrEC/PrEC.MD CpG merged methylation levels"
# chr1	540799	540801	0	0	1
# chr1	540807	540809	0	0	1
# to:
# chr	position	LNCaP.C		LNCaP.cov
# chr1	10469		3		5
# chr1	10471		0		1
echo " *** Convert CpG strands bedGraph to bed" >> $LOGFILE
echo `date`" - CpG strands" >> $LOGFILE
cmd="""
bedtools intersect -a ${GENOME/.fa/.CpG.strands.bed} -b ${output}/${sample}.MD.strands_CpG.bedGraph -loj| awk '{OFS=\"\t\"}{if(\$11==-1){\$11=\$12=0}; print \$1,\$2,\$3,\$6,\$11,\$11+\$12}' > ${output}/${sample}.MD.CpG.strands.bed
"""
echo $cmd >> "$LOGFILE"; eval $cmd 2>> "$LOGFILE"; echo -e `date`" Finished - CpG strands\n" >> $LOGFILE

echo `date`" - CHG strands" >> $LOGFILE
cmd="""
bedtools intersect -a ${GENOME/.fa/.CHG.strands.bed} -b ${output}/${sample}.MD.strands_CHG.bedGraph -loj| awk '{OFS=\"\t\"}{if(\$11==-1){\$11=\$12=0}; print \$1,\$2,\$3,\$6,\$11,\$11+\$12}' > ${output}/${sample}.MD.CHG.strands.bed
"""
echo $cmd >> "$LOGFILE"; eval $cmd 2>> "$LOGFILE"; echo -e `date`" Finished - CHG strands\n" >> $LOGFILE

echo `date`" - CHA strands" >> $LOGFILE
cmd="""
bedtools intersect -a ${GENOME/.fa/.CHA.strands.bed} -b ${output}/${sample}.MD.strands_CHH.bedGraph -loj| awk '{OFS=\"\t\"}{if(\$11==-1){\$11=\$12=0}; print \$1,\$2,\$3,\$6,\$11,\$11+\$12}' > ${output}/${sample}.MD.CHA.strands.bed
"""
echo $cmd >> "$LOGFILE"; eval $cmd 2>> "$LOGFILE"; echo -e `date`" Finished - CHA strands\n" >> $LOGFILE

echo `date`" - CHC strands" >> $LOGFILE
cmd="""
bedtools intersect -a ${GENOME/.fa/.CHC.strands.bed} -b ${output}/${sample}.MD.strands_CHH.bedGraph -loj| awk '{OFS=\"\t\"}{if(\$11==-1){\$11=\$12=0}; print \$1,\$2,\$3,\$6,\$11,\$11+\$12}' > ${output}/${sample}.MD.CHC.strands.bed
"""
echo $cmd >> "$LOGFILE"; eval $cmd 2>> "$LOGFILE"; echo -e `date`" Finished - CHC strands\n" >> $LOGFILE

echo `date`" - CHT strands" >> $LOGFILE
cmd="""
bedtools intersect -a ${GENOME/.fa/.CHT.strands.bed} -b ${output}/${sample}.MD.strands_CHH.bedGraph -loj| awk '{OFS=\"\t\"}{if(\$11==-1){\$11=\$12=0}; print \$1,\$2,\$3,\$6,\$11,\$11+\$12}' > ${output}/${sample}.MD.CHT.strands.bed
"""
echo $cmd >> "$LOGFILE"; eval $cmd 2>> "$LOGFILE"; echo -e `date`" Finished - CHT strands\n" >> $LOGFILE

echo `date`" - Lambda in CpG strands" >> $LOGFILE
echo " Get only lambda from MethylDackel strands output" >> $LOGFILE
cmd="""
grep lambda ${output}/${sample}.MD.strands_CpG.bedGraph ${output}/${sample}.MD.strands_CHG.bedGraph ${output}/${sample}.MD.strands_CHH.bedGraph| cut -d: -f2| sort -k2,2n > ${output}/${sample}.MD.lambda.strands.bedGraph
"""
echo $cmd >> "$LOGFILE"; eval $cmd 2>> "$LOGFILE"

cmd="""
bedtools intersect -a ${GENOME/hg19.fa/lambda.C.strands.bed} -b ${output}/${sample}.MD.lambda.strands.bedGraph -loj| awk '{OFS=\"\t\"}{if(\$11==-1){\$11=\$12=0}; print \$1,\$2,\$3,\$6,\$11,\$11+\$12}' > ${output}/${sample}.MD.lambda.strands.bed
"""
echo $cmd >> "$LOGFILE"; eval $cmd 2>> "$LOGFILE"; echo -e `date`" Finished - lambda strands\n" >> $LOGFILE


# merg context 
# chr positions positione LNCaP.C   LNCaP.cov
# chr1  10468   10470   0   0
# chr1  10470   10472   0   0

echo `date`" *** Convert merged context CpG bedGraph to bed" >> $LOGFILE
echo -e "#chr\tpositions\tpositione\t${sample}.C\t${sample}.cov" > "${output}/${sample}.MD.CpG.bed"
echo " - CpG" >> $LOGFILE
cmd="""
bedtools intersect -a ${GENOME/.fa/.CpG.bed} -b ${output}/${sample}.MD_CpG.bedGraph -loj| grep -v lambda| awk '{OFS=\"\t\"}{if(\$8==-1){\$8=\$9=0}; print \$1,\$2,\$3,\$8,\$9}' >> ${output}/${sample}.MD.CpG.bed
"""
echo $cmd >> "$LOGFILE"; eval $cmd 2>> "$LOGFILE"; echo -e `date`" Finished - merge context CpG\n" >> $LOGFILE


echo "*** Zip output file"  >> $LOGFILE
cmd="""
bgzip ${output}/${sample}.MD.CpG.strands.bed;
bgzip ${output}/${sample}.MD.CHG.strands.bed;
bgzip ${output}/${sample}.MD.CHH.strands.bed;
bgzip ${output}/${sample}.MD.lambda.strands.bed;
bgzip ${output}/${sample}.MD.CpG.bed;
"""
echo $cmd >> "$LOGFILE"; eval $cmd 2>> "$LOGFILE"; echo -e `date`" Zip output\n" >> $LOGFILE

echo "*** Clean up" >> $LOGFILE
cmd="""
rm "${output}/${sample}.MD.strands_C*.bedGraph";
rm "${output}/${sample}.MD_C*.bedGraph";
"""
echo $cmd >> "$LOGFILE"; eval $cmd 2>> "$LOGFILE"
echo `date`" - Finished DNA methylation calling with MethylDackel" >> $LOGFILE


