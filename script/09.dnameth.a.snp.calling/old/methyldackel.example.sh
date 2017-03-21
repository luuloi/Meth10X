
module load gi/bedtools/2.22.0
MethylDackel="/home/phuluu/methods/DNAmeth.calling.method.comparison/MethylDackel/bin/MethylDackel"
sample="PrEC"
output="/home/phuluu/data/WGBS10X_new/Test_Prostate/called/PrEC/"
GENOME="/home/phuluu/Projects/WGBS10X_new/V02/annotations/hg19/hg19.fa"
CpG=${GENOME/.fa/.CpG.bed}
##chr	position	PrEC.C	PrEC.cov
#chr1	540799	0	1
LOGFILE="/home/phuluu/data/WGBS10X_new/Test_Prostate/merged/PrEC/PrEC.MethylDackel.log"
input="/home/phuluu/data/WGBS10X_new/Test_Prostate/merged/LNCaP/LNCaP.bam"
$MethylDackel extract --nOT 1,1,1,1 --nOB 1,1,1,1 --nCTOT 1,1,1,1 --nCTOB 1,1,1,1 \
                      -q 60 \
                      -p 20 \
                      -d 1 \
                      -D 100000 \
                      -o "${output}/${sample}.MD.strands" \
                      --CHG \
                      --CHH \
                      $GENOME $input 2>> $LOGFILE

# ${output}/${sample}.MD_CpG.bedGraph
head ${output}/${sample}.MD_CpG.bedGraph
track type="bedGraph" description="/home/phuluu/data/WGBS10X_new/Test_Prostate/called/PrEC//PrEC.MD CpG merged methylation levels"
chr1	540799	540801	0	0	1
chr1	540807	540809	0	0	1
chr1	540816	540818	0	0	1
cmd="""
awk '{OFS=\"\t\"}NR>1{print \$1,\$2,\$2,\$5,\$5+\$6}' ${output}/${sample}.MD_CpG.bedGraph > ${output}/${sample}.MD_CpG.bed
"""
echo $cmd
# awk '{OFS="\t"}NR>1{print $1,$2,$2,$5,$5+$6}' /home/phuluu/data/WGBS10X_new/Test_Prostate/called/PrEC//PrEC.MD_CpG.bedGraph > /home/phuluu/data/WGBS10X_new/Test_Prostate/called/PrEC//PrEC.MD_CpG.bed
eval $cmd
head ${output}/${sample}.MD_CpG.bed
chr1	540799	540799	0	1
chr1	540807	540807	0	1



# bedtools intersect -a $CpG -b ${output}/${sample}.MD_CpG.bed -loj| awk '{OFS="\t"}{print $1,$2,$2,$7,$8}' > ${output}/${sample}.MD_CpG.tsv

bedtools intersect -a <(head -n 100000 $CpG) -b <(head -n 10000 ${output}/${sample}.MD_CpG.bed) -loj| awk '{OFS="\t"}{if($8==-1){$7=0;$8=0}; print $1,$2,$2,$7,$8}'

bedtools intersect -a $CpG -b ${output}/${sample}.MD_CpG.bed -loj|\
awk '{OFS="\t"}{if($8==-1){$7=0;$8=0}; print $1,$2,$2,$7,$8}'| egrep -v ">lambda" 



# lambda genome after run the script make_lambda_tsv.R
head /home/phuluu/Projects/WGBS10X_new/V02/annotations/hg19//lambda.CpG.strands.bed
lambda	0	1	.	0	-
lambda	1	2	.	0	-
lambda	2	3	.	0	-
lambda	3	4	.	0	+
lambda	4	5	.	0	-
lambda	5	6	.	0	-
lambda	6	7	.	0	+
lambda	7	8	.	0	-
lambda	9	10	.	0	+
lambda	10	11	.	0	+

# output from Darlo
zcat '/home/phuluu/mount/gdata3/Cancer-Epigenetics-Data/Bis-Seq_Level_3/darlo_luu/CML/calls/JW_01/JW_01.lambda.strand.tsv.gz' | head
chr	position	strand	JW_01.C	JW_01.cov
lambda	1	-	0	0
lambda	2	-	0	0
lambda	3	-	0	0
lambda	4	+	0	0
lambda	5	-	0	0
lambda	6	-	0	0
lambda	7	+	0	0
lambda	8	-	0	0
lambda	10	+	0	0

grep "lambda" /home/phuluu/data/WGBS10X_new/Test_Prostate/called/PrEC//PrEC.MD.strands_CpG.bedGraph| head
# lambda	3	4	0	0	1
# lambda	6	7	0	0	1
# lambda	12	13	0	0	1
# lambda	13	14	0	0	1
# lambda	14	15	0	0	1

bedtools intersect -a ${GENOME/hg19.fa/lambda.CpG.strands.bed} -b <(grep "lambda" /home/phuluu/data/WGBS10X_new/Test_Prostate/called/PrEC//PrEC.MD.strands_CpG.bedGraph) -loj| head | column -t
# lambda  0   1   .  0  -  .       -1  -1  .  -1  .
# lambda  1   2   .  0  -  .       -1  -1  .  -1  .
# lambda  2   3   .  0  -  .       -1  -1  .  -1  .
# lambda  3   4   .  0  +  lambda  3   4   0  0   1
# lambda  4   5   .  0  -  .       -1  -1  .  -1  .
# lambda  5   6   .  0  -  .       -1  -1  .  -1  .
# lambda  6   7   .  0  +  lambda  6   7   0  0   1

bedtools intersect -a ${GENOME/hg19.fa/lambda.CpG.strands.bed} -b <(grep "lambda" /home/phuluu/data/WGBS10X_new/Test_Prostate/called/PrEC//PrEC.MD.strands_CpG.bedGraph) -loj|\
awk '{OFS="\t"}{if($11==-1){$11=$12=0} print $1,$3,$6,$11,$11+$12}'| head
# lambda	1	-	0	0
# lambda	2	-	0	0
# lambda	3	-	0	0
# lambda	4	+	0	1
# lambda	5	-	0	0
# lambda	6	-	0	0
# lambda	7	+	0	1
# lambda	8	-	0	0

# CpG strands
head /home/phuluu/Projects/WGBS10X_new/V02/annotations/hg19/hg19.CpG.strands.bed
chr1	10468	10469	.	0	+
chr1	10469	10470	.	0	-
chr1	10470	10471	.	0	+
chr1	10471	10472	.	0	-
chr1	10483	10484	.	0	+

bedtools intersect -a <(head -n 9000 ${GENOME/.fa/.CpG.strands.bed}) -b <(head -n 1000 /home/phuluu/data/WGBS10X_new/Test_Prostate/called/PrEC//PrEC.MD.strands_CpG.bedGraph) -loj
chr1	540749	540750	.	0	+	.	-1	-1	.	-1	.
chr1	540750	540751	.	0	-	.	-1	-1	.	-1	.
chr1	540799	540800	.	0	+	chr1	540799	540800	0	0	1
chr1	540800	540801	.	0	-	.	-1	-1	.	-1	.
chr1	540807	540808	.	0	+	chr1	540807	540808	0	0	1
chr1	540808	540809	.	0	-	.	-1	-1	.	-1	.
chr1	540816	540817	.	0	+	chr1	540816	540817	0	0	1
chr1	540817	540818	.	0	-	.	-1	-1	.	-1	.
chr1	540824	540825	.	0	+	chr1	540824	540825	100	1	0
chr1	540825	540826	.	0	-	.	-1	-1	.	-1	.
chr1	540826	540827	.	0	+	chr1	540826	540827	100	1	0
chr1	540827	540828	.	0	-	.	-1	-1	.	-1	.
chr1	540836	540837	.	0	+	chr1	540836	540837	0	0	1
chr1	540837	540838	.	0	-	.	-1	-1	.	-1	.
chr1	540838	540839	.	0	+	chr1	540838	540839	100	1	0
chr1	540839	540840	.	0	-	.	-1	-1	.	-1	.
chr1	540841	540842	.	0	+	.	-1	-1	.	-1	.
chr1	540842	540843	.	0	-	.	-1	-1	.	-1	.
chr1	540850	540851	.	0	+	chr1	540850	540851	100	1	0

bedtools intersect -a <(head -n 9000 ${GENOME/.fa/.CpG.strands.bed}) -b <(head -n 1000 /home/phuluu/data/WGBS10X_new/Test_Prostate/called/PrEC//PrEC.MD.strands_CpG.bedGraph) -loj|\
 awk '{OFS="\t"}{if($11==-1){$11=$12=0}; print $1,$3,$6,$11,$11+$12}'
chr1	540800	+	0	1
chr1	540801	-	0	0
chr1	540808	+	0	1
chr1	540809	-	0	0
chr1	540817	+	0	1
chr1	540818	-	0	0
chr1	540825	+	1	1
chr1	540826	-	0	0
chr1	540827	+	1	1
chr1	540828	-	0	0
chr1	540837	+	0	1
chr1	540838	-	0	0
chr1	540839	+	1	1
chr1	540840	-	0	0

# CpG merged context
bedtools intersect -a ${GENOME/.fa/.CpG.bed} -b ${output}/${sample}.MD_CpG.bedGraph -loj
chr1    540749  540751  .       -1      -1      .       -1      .
chr1    540799  540801  chr1    540799  540801  0       0       1
chr1    540807  540809  chr1    540807  540809  0       0       1
chr1    540816  540818  chr1    540816  540818  0       0       1
chr1    540824  540826  chr1    540824  540826  100     1       0
chr1    540826  540828  chr1    540826  540828  100     1       0
chr1    540836  540838  chr1    540836  540838  0       0       1
chr1    540838  540840  chr1    540838  540840  100     1       0
chr1    540841  540843  .       -1      -1      .       -1      .
chr1    540850  540852  chr1    540850  540852  100     1       0
chr1    540854  540856  .       -1      -1      .       -1      .
bedtools intersect -a ${GENOME/.fa/.CpG.bed} -b ${output}/${sample}.MD_CpG.bedGraph -loj| awk '{OFS="\t"}{if($8==-1){$8=$9=0} print $1,$2,$3,$8,$9}'| head
chr1	10468	10470	0	0
chr1	10470	10472	0	0
chr1	10483	10485	0	0
chr1	10488	10490	0	0
chr1	10492	10494	0	0
chr1	10496	10498	0	0
chr1	10524	10526	0	0
bedtools intersect -a ${GENOME/.fa/.CpG.bed} -b ${output}/${sample}.MD_CpG.bedGraph -loj| awk '{OFS="\t"}{if($8==-1){$8=$9=0} print $1,$2,$3,$8,$9}'