# make vcf snp output
vcf="/home/phuluu/data/WGBS10X_new/Test_Prostate/called/PrEC/PrEC.BC.vcf"
# End of header: 
# #CHROM	POS	ID	REF	ALT	QUAL	FILTER	INFO	FORMAT	PrEC
grep -m 1 -B $(grep -m 1 -n "#CHROM" $vcf|cut -d: -f1) "#CHROM" $vcf > PrEC.BC.snp.vcf
bedtools intersect -a data/WGBS10X_new/Test_Prostate/called/PrEC/PrEC.BC.vcf -b data/WGBS10X_new/Test_Prostate/called/PrEC/PrEC.BC.snp.bed -wa > PrEC.BC.snp.vcf
# chr1	10241	.	T	R	26	PASS	NS=1	DP:GT:GP:GQ:SP	1:1/1:6,8,0:26:R1
# chr1	10278	.	C	R	26	PASS	NS=1	DP:GT:GP:GQ:SP	1:1/1:6,8,0:26:R1
# chr1	10279	.	T	G	26	PASS	NS=1	DP:GT:GP:GQ:SP	1:1/1:6,8,0:26:G1

grep -m 1 -B $(grep -m 1 -n "#CHROM" $vcf|cut -d: -f1) "#CHROM" $vcf > data/WGBS10X_new/Test_Prostate/called/LNCaP/LNCaP.BC.snp.vcf
bedtools intersect -a data/WGBS10X_new/Test_Prostate/called/LNCaP/LNCaP.BC.vcf -b data/WGBS10X_new/Test_Prostate/called/LNCaP/LNCaP.BC.snp.bed -wa >> data/WGBS10X_new/Test_Prostate/called/LNCaP/LNCaP.BC.snp.vcf

grep -m 1 -B $(grep -m 1 -n "#CHROM" $vcf|cut -d: -f1) "#CHROM" $vcf > data/WGBS10X_new/Test_Prostate/called/PrEC/PrEC.BC.snp.vcf
bedtools intersect -a data/WGBS10X_new/Test_Prostate/called/PrEC/PrEC.BC.vcf -b data/WGBS10X_new/Test_Prostate/called/PrEC/PrEC.BC.snp.bed -wa >> data/WGBS10X_new/Test_Prostate/called/PrEC/PrEC.BC.snp.vcf


#### merge vcf file
module load gi/tabix/0.2.6
export PERL5LIB=/share/ClusterShare/software/contrib/phuluu/vcftools/src/perl/:$PERL5LIB

bgzip /home/phuluu/data/WGBS10X_new/Test_Prostate/called/PrEC/PrEC.BC.snp.vcf
tabix -fp vcf /home/phuluu/data/WGBS10X_new/Test_Prostate/called/PrEC/PrEC.BC.snp.vcf.gz
bgzip /home/phuluu/data/WGBS10X_new/Test_Prostate/called/LNCaP/LNCaP.BC.snp.vcf
tabix -fp vcf /home/phuluu/data/WGBS10X_new/Test_Prostate/called/LNCaP/LNCaP.BC.snp.vcf.gz

/share/ClusterShare/software/contrib/phuluu/vcftools/bin/vcf-merge \
/home/phuluu/data/WGBS10X_new/Test_Prostate/called/PrEC/PrEC.BC.snp.vcf.gz \
/home/phuluu/data/WGBS10X_new/Test_Prostate/called/LNCaP/LNCaP.BC.snp.vcf.gz \
> /home/phuluu/data/WGBS10X_new/Test_Prostate/bigTables/bigTable.BC.snp.vcf

