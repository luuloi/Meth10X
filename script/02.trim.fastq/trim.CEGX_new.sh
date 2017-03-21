#!/bin/bash -e

# load module 
export MODULEPATH=/share/ClusterShare/Modules/modulefiles/noarch:/share/ClusterShare/Modules/modulefiles/centos6.2_x86_64:/share/ClusterShare/Modules/modulefiles/contrib:$MODULEPATH 
export PATH=/home/phuluu/bin:$PATH
source /etc/profile.d/modules.sh
module load gi/java/jdk1.8.0_25
module load gi/fastqc/0.11.5

# $1=raw/LNCaP/TKCC20140123_LNCaP_P73_Test/TKCC20140123_LNCaP_P73_Test_R1.fastq.gz
# $2=raw_trimmed/LNCaP/TKCC20140123_LNCaP_P73_Test_trimmed/TKCC20140123_LNCaP_P73_Test_trimmed_R1.fastq
# $3=raw/LNCaP/TKCC20140123_LNCaP_P73_Test/TKCC20140123_LNCaP_P73_Test_R2.fastq.gz
# $4=raw_trimmed/LNCaP/TKCC20140123_LNCaP_P73_Test_trimmed/TKCC20140123_LNCaP_P73_Test_trimmed_R2.fastq
# $5=raw_trimmed/LNCaP/TKCC20140123_LNCaP_P73_Test_trimmed/
LOGFILE="${2/_R1.fastq.gz/}.trim.log"
echo `date`" *** Start trim the GEGX fastq file" > $LOGFILE
echo " - Trimming" >> $LOGFILE
length_thres=40
R1="$1"
R2="$3"
O1="$2"
O2="$4"

# DNA from 5' to 3' in R1: Trim 6 bases from 3' of R1 (trim at the end of R1)
# DNA from 5' to 3' in R2: Trim 6 bases from 5' of R2 (trim at the start of R2)

cmd="""
paste <(gunzip < $R1| paste -d\"\t\" - - - -) <(gunzip < $R2| paste -d\"\t\" - - - -)|\
awk -F\"\t\" '{OFS=\"\n\"}{id2=\$5; gsub(/2:N/,\"1:N\",id2); s1=length(\$2); q1=length(\$4); s2=length(\$6); q2=length(\$8);\
if((s1<length_thres)||(S2<length_thres)){next;}else if((\$1==id2)&&(\$3==\$7)&&((s1-q1+s2-q2)==0)){print \$1, substr(\$2,1,s1-6), \$3, substr(\$4,1,q1-6)|\"gzip > $O1\"; print \$5, substr(\$6,7,s2), \$3, substr(\$8,7,q2)|\"gzip > $O2\";}else{print \"Error occurred at line\",NR; exit;}}'
"""
echo $cmd >> $LOGFILE; eval $cmd >> $LOGFILE 2>&1

echo " - QC after trimmed" >> $LOGFILE
cmd="fastqc -t 48 -o $5 $O1 $O2"
echo $cmd >> $LOGFILE; eval $cmd >> $LOGFILE 2>&1
echo `date`"- Finished the trimming" >> $LOGFILE

# # manual checking
# cd ~/data/WGBS10X_new
# t="Test_Prostate/raw_trimmed/LNCaP/TKCC20140123_LNCaP_P73_Test_trimmed/TKCC20140123_LNCaP_P73_Test_trimmed_R1.fastq.gz"
# t1="Test_Prostate1/raw_trimmed/LNCaP/TKCC20140123_LNCaP_P73_Test_trimmed/TKCC20140123_LNCaP_P73_Test_trimmed_R1.fastq.gz"
# paste <(zcat $t| paste - - - -) <(zcat $t1| paste - - - -)| awk 'NR==6{print $3"\n"$8; exit}'
# TNTTTAGTTTTTTACGTGGAAGCGGGATTTGTTGAGGATGGAGTAGATGAGGGTTTTATAGAGAATGGTAGTGGTTTTTTGAATTTGTGGGTTT
# TNTTTAGTTTTTTACGTGGAAGCGGGATTTGTTGAGGATGGAGTAGATGAGGGTTTTATAGAGAATGGTAGTGGTTTTTTGAATTTGTGGGTTT
# phuluu@dice02:$ a1="Test_Prostate1/raw/LNCaP/TKCC20140123_LNCaP_P73_Test/TKCC20140123_LNCaP_P73_Test_R1.fastq.gz"
# a="Test_Prostate/raw/LNCaP/TKCC20140123_LNCaP_P73_Test/TKCC20140123_LNCaP_P73_Test_R1.fastq.gz"
# paste <(zcat $a| paste - - - -) <(zcat $a1| paste - - - -)| awk 'NR==6{print $3"\n"$8; exit}'
# TNTTTAGTTTTTTACGTGGAAGCGGGATTTGTTGAGGATGGAGTAGATGAGGGTTTTATAGAGAATGGTAGTGGTTTTTTGAATTTGTGGGTTTTTATGAT
# TNTTTAGTTTTTTACGTGGAAGCGGGATTTGTTGAGGATGGAGTAGATGAGGGTTTTATAGAGAATGGTAGTGGTTTTTTGAATTTGTGGGTTTTTATGAT
# paste <(zcat $a| paste - - - -) <(zcat $a1| paste - - - -)| awk 'NR==235698{print $3"\n"$8; exit}'
# AGGAAGTGTATATAAGTATAGTGTTTTAGTTAATAAAGTTGTTTTTTATGGAAGTATGGTGTAATGTTTTTGATATTATTGTATATGTATATTGTGAATGA
# AGGAAGTGTATATAAGTATAGTGTTTTAGTTAATAAAGTTGTTTTTTATGGAAGTATGGTGTAATGTTTTTGATATTATTGTATATGTATATTGTGAATGA
# paste <(zcat $t| paste - - - -) <(zcat $t1| paste - - - -)| awk 'NR==235698{print $3"\n"$8; exit}'
# AGGAAGTGTATATAAGTATAGTGTTTTAGTTAATAAAGTTGTTTTTTATGGAAGTATGGTGTAATGTTTTTGATATTATTGTATATGTATATTG
# AGGAAGTGTATATAAGTATAGTGTTTTAGTTAATAAAGTTGTTTTTTATGGAAGTATGGTGTAATGTTTTTGATATTATTGTATATGTATATTG

# R1="raw/JW_08/HGJ3VALXX_2_JW_8_Human_TGACCA_R_170201_SHANAI_WGBSLIB_M001/HGJ3VALXX_2_JW_8_Human_TGACCA_R_170201_SHANAI_WGBSLIB_M001_R1.fastq.gz"
# R2="raw/JW_08/HGJ3VALXX_2_JW_8_Human_TGACCA_R_170201_SHANAI_WGBSLIB_M001/HGJ3VALXX_2_JW_8_Human_TGACCA_R_170201_SHANAI_WGBSLIB_M001_R2.fastq.gz"

# paste <(gunzip < $R1| paste -d "\t" - - - -) <(gunzip < $R2| paste -d"\t" - - - -)|\
# awk -F"\t" '{OFS="\n"}{id2=$5; gsub(/2:N/,"1:N",id2); s1=length($2); q1=length($4); s2=length($6); q2=length($8);\
# if((s1<length_thres)||(S2<length_thres)){ 
# 	next; 
# }
# else if(($1==id2)&&($3==$7)&&(s1==q1)&&(s2==q2)){
# 	print $1, substr($2,1,s1-6), $3, substr($4,1,q1-6); 
# 	print $5, substr($6,7,s2), $3, substr($8,7,q2);
# }}'|\
# head

