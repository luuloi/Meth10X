module load phuluu/python/2.7.8
module load gi/java/jdk1.7.0_45
module load aarsta/bwa/0.7.9a

bwameth.py tabulate \
--trim 1,1 \
--bissnp /home/darloluu/projects/WGBS10X/script/08.bisSNP/BisSNP-0.82.2.jar \
--map-q 60 \
--threads 4 \
--prefix /home/darloluu/called/LNCaP.chr7.bissnp \
--reference /home/darloluu/methods/darlo/annotations/hg19/hg19.fa \
--region chr7 \
--context all \
/home/darloluu/tmp1/Test_Prostate/merged/LNCaP/LNCaP.bam
