bedtools intersect -a <(bedtools makewindows -g $GSIZE -w 100) -b "$OUTPUT/${sample}.bedGraph" -loj| awk '{OFS="\t"}{if($7=="."){$7=-1}; print $1,$2,$3,$7}'|
bedtools groupby -i tmp.bed -g 1,2,3 -c 4 -o collapse |
awk '{OFS="\t"}{gsub("-1,|-1|","",$4); if($4!=""){split($4,a,","); for(i=1;i<length(a);i++){s=s+a[i]}; print $1,$2,$3,s/(i-1); print $0; s=0;}else{print $1,$2,$3,-1}}'
