cmd="""nrow=\$(wc -l a.bed| awk '{print \$1}') """
echo $cmd; eval $cmd
echo -e "chr\tposition\tstrand\t${sample}.C\t${sample}.cov" > "a.tsv"
# zcat MCF7.lambda.strand.tsv.gz| head -n 3
# chr     position  strand  MCF7.C  MCF7.cov
# lambda  1         -       0       0
# lambda  2         -       0       0

# ${output}/${sample}.MD.strands_lambda.bedGraph
# lambda  3 4 0 0 1
# lambda  6 7 0 0 1
cmd="""
if [ $nrow -eq 0 ]; then
  echo -e \"lambda\t0\t1\t0\t0\t0\" >> "a.tsv";
fi
"""
echo $cmd; eval $cmd
