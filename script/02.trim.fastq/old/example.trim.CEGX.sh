paste <(paste -d"\t" - - - - < a1.fastq) <(paste -d"\t" - - - - < a2.fastq)| \
awk -F"\t" '{OFS="\n"}{id2=$5; gsub(/2:N/,"1:N",id2);s1=length($2);q1=length($4);s2=length($6);q1=length($8); \
if(($1==id2)&&($3==$7)&&(s1-s2+q1-q2==0)){print $1, substr($2,1,s1-7), $3, substr($4,1,s1-7) > "a1_b.fastq"; print $5, substr($6,7,s1), $3, substr($4,7,s1)) > "a2_b.fastq"}}'


# good one
paste <(paste -d"\t" - - - - < a1.fastq) <(paste -d"\t" - - - - < a2.fastq)| \
awk -F"\t" '{OFS="\n"}{id2=$5; gsub(/2:N/,"1:N",id2); s1=length($2); q1=length($4); s2=length($6); q2=length($8); \
if(($1==id2)&&($3==$7)&&((s1-q1+s2-q2)==1)){print $1, substr($2,1,s1-7), $3, substr($4,1,q1-7) > "a1_b.fastq"; print $5, substr($6,7,s2), $3, substr($4,7,q2) > "a2_b.fastq"}else{print NR; exit}}'


paste <(paste -d"\t" - - - - < a1.fastq) <(paste -d"\t" - - - - < a2.fastq)| \
awk -F"\t" '{OFS="\n"}{id2=$5; gsub(/2:N/,"1:N",id2); s1=length($2); q1=length($4); s2=length($6); q2=length($8); \
if(($1==id2)&&($3==$7)&&((s1-q1+s2-q2)==0)){print $1, substr($2,1,s1-7), $3, substr($4,1,q1-7) > "a1_b.fastq"; print $5, substr($6,7,s2), $3, substr($4,7,q2) > "a2_b.fastq"}else{print NR; exit}}'| \
{ read a; echo $a; [[ $a -ge 1 ]] && exit 1;}


paste <(gunzip < a1.fastq.gz| paste -d"\t" - - - -) <(gunzip < a2.fastq.gz| paste -d"\t" - - - -)| \
awk -F"\t" '{OFS="\n"}{id2=$5; gsub(/2:N/,"1:N",id2); s1=length($2); q1=length($4); s2=length($6); q2=length($8); \
if(($1==id2)&&($3==$7)&&((s1-q1+s2-q2)==0)){print $1, substr($2,1,s1-7), $3, substr($4,1,q1-7) > "a1_b.fastq"; print $5, substr($6,7,s2), $3, substr($4,7,q2) > "a2_b.fastq"}else{print NR; exit}}'| \
{ read a; echo $a; [[ $a -ge 1 ]] && exit 1;}

paste <(gunzip < a1.fastq.gz| paste -d"\t" - - - -) <(gunzip < a2.fastq.gz| paste -d"\t" - - - -)| awk -F"\t" '{OFS="\n"}{id2=$5; gsub(/2:N/,"1:N",id2); s1=length($2); q1=length($4); s2=length($6); q2=length($8); \
if(($1==id2)&&($3==$7)&&((s1-q1+s2-q2)==0)){print $1, substr($2,1,s1-7), $3, substr($4,1,q1-7); print $5, substr($6,7,s2), $3, substr($4,7,q2)}else{print NR; exit}}'


R1="a1.fastq.gz"
R2="a2.fastq.gz"
O1=${R1/.fastq.gz/_trimmed.fastq.gz}
O2=${R2/.fastq.gz/_trimmed.fastq.gz}

paste <(gunzip < "$R1"| paste -d"\t" - - - -) <(gunzip < "$R2"| paste -d"\t" - - - -)| \
awk -F"\t" '{OFS="\n"}{id2=$5; gsub(/2:N/,"1:N",id2); s1=length($2); q1=length($4); s2=length($6); q2=length($8); \
if(($1==id2)&&($3==$7)&&((s1-q1+s2-q2)==0)){print $1, substr($2,1,s1-7), $3, substr($4,1,q1-7)"| gzip > $O1"; print $5, substr($6,7,s2), $3, substr($4,7,q2)"| gzip > $O2"}else{print NR; exit}}'



cmd="""
paste <(gunzip < $R1| paste -d\"\t\" - - - -) <(gunzip < $R2| paste -d\"\t\" - - - -)|\
awk -F\"\t\" '{OFS=\"\n\"}{id2=\$5; gsub(/2:N/,\"1:N\",id2); s1=length(\$2); q1=length(\$4); s2=length(\$6); q2=length(\$8);\
if((\$1==id2)&&(\$3==\$7)&&((s1-q1+s2-q2)==0)){print \$1, substr(\$2,1,s1-7), \$3, substr(\$4,1,q1-7)|\"gzip > $O1\"; print \$5, substr(\$6,7,s2), \$3, substr(\$4,7,q2)|\"gzip > $O2\"}else{print "Error occurred at line",NR; exit}}'
"""


