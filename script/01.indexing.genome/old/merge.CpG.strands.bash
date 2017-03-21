# merge CpG strands into one strand 
# output generate
# wc -l data/annotations/hg19/hg19.CpG.strands.bed
# 56539954 data/annotations/hg19/hg19.CpG.strands.bed
# head data/annotations/hg19/hg19.CpG.strands.bed
# chr1	10468	10469	.	0	+
# chr1	10469	10470	.	0	-
# chr1	10470	10471	.	0	+
# head data/annotations/hg19/hg19.CHG.strands.bed
# 248049196 data/annotations/hg19/hg19.CHG.strands.bed
# chr1	10472	10473	.	0	-
# chr1	10479	10480	.	0	+
# chr1	10481	10482	.	0	-
# less data/annotations/hg19/hg19.CHH.strands.bed
# 867363557 data/annotations/hg19/hg19.CHH.strands.bed
# chr1    11315   11316   .       0       +
# chr1    11316   11317   .       0       +
# chr1    11318   11319   .       0       +
# chr1    11321   11322   .       0       -
# chr1    11322   11323   .       0       +
# chr1    11333   11334   .       0       -
# chr1    11335   11336   .       0       -

# Here is output from Darlo
# zcat '/home/phuluu/mount/gdata3/Cancer-Epigenetics-Data/Bis-Seq_Level_3/darlo_luu/CML/calls/JW_01/JW_01.CpG.tsv.gz'  |head
# chr	position	JW_01.C	JW_01.cov
# chr1	10469	0	0
# chr1	10471	0	0
# chr1	10484	0	0
# chr1	10489	0	0
# chr1	10493	0	0
# chr1	10497	0	0
# chr1	10525	0	0
# chr1	10542	0	0

awk '{OFS="\t"}{if($6=="+") print $1,$2,$3+1}' /home/phuluu/Projects/WGBS10X_new/V02/annotations/hg19/hg19.CpG.strands.bed > /home/phuluu/Projects/WGBS10X_new/V02/annotations/hg19/hg19.CpG.bed

head data/WGBS10X_new/Test_Prostate/called/PrEC/PrEC.bedGraph
==> data/WGBS10X_new/Test_Prostate/called/PrEC/PrEC.MD_CHG.bedGraph <==
track type="bedGraph" description="/home/phuluu/data/WGBS10X_new/Test_Prostate/called/PrEC//PrEC.MD CHG merged methylation levels"
chr1	86276	86279	0	0	1
chr1	86291	86294	0	0	1
chr1	540763	540766	0	0	1
chr1	540781	540784	0	0	1
chr1	540804	540807	0	0	1
chr1	540812	540815	0	0	1
chr1	540845	540848	0	0	1
chr1	648903	648906	0	0	1
chr1	718531	718534	0	0	1

==> data/WGBS10X_new/Test_Prostate/called/PrEC/PrEC.MD_CHH.bedGraph <==
track type="bedGraph" description="/home/phuluu/data/WGBS10X_new/Test_Prostate/called/PrEC//PrEC.MD CHH merged methylation levels"
chr1	86289	86290	0	0	1
chr1	86302	86303	0	0	1
chr1	86311	86312	0	0	1
chr1	86318	86319	0	0	1
chr1	86328	86329	0	0	1
chr1	86329	86330	0	0	1
chr1	86343	86344	0	0	1
chr1	86347	86348	0	0	1
chr1	540759	540760	0	0	1

==> data/WGBS10X_new/Test_Prostate/called/PrEC/PrEC.MD_CpG.bedGraph <==
track type="bedGraph" description="/home/phuluu/data/WGBS10X_new/Test_Prostate/called/PrEC//PrEC.MD CpG merged methylation levels"
chr1	540799	540801	0	0	1
chr1	540807	540809	0	0	1
chr1	540816	540818	0	0	1
chr1	540824	540826	100	1	0
chr1	540826	540828	100	1	0
chr1	540836	540838	0	0	1
chr1	540838	540840	100	1	0
chr1	540850	540852	100	1	0
chr1	718571	718573	100	1	0



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
zcat '/home/phuluu/mount/gdata3/Cancer-Epigenetics-Data/Bis-Seq_Level_3/darlo_luu/CML/calls/JW_01/JW_01.lambda.strand.tsv.gz'  |head
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
