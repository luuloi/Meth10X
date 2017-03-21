INPUTS="/home/darloluu/tmp/Test_Prostate/called/LNCaP/LNCaP.lambda.strand.tsv.gz /home/darloluu/tmp/Test_Prostate/called/PrEC/PrEC.lambda.strand.tsv.gz"
OUTPUT="/home/darloluu/tmp/Test_Prostate/bigTables"
COUNT=2
fname="lambda.strand.tsv.gz"

if [[ $COUNT -gt 1 ]]; then
	# header
	header="chr\tposition\tstrand"
	for i in $INPUTS;
	do
		sample=$(basename $i);
		header="${header}\t${sample/".$fname"/.C}\t${sample/".$fname"/.cov}";
	done;
	echo -e $header | gzip -c > "$OUTPUT/$fname";
	# body
	pfname1=$(echo $INPUTS| cut -d ' ' -f1)
	cmd="paste <(gunzip -c $pfname1)"
	for i in $(seq 2 $COUNT);
	do
		pfname1=$(echo $INPUTS| cut -d ' ' -f$i)
		cmd="$cmd <(gunzip -c $pfname1| cut -f4,5)"; 
	done; 
	cmd="$cmd | gzip -c >> $OUTPUT/$fname";
	eval $cmd 
else
	cp $INPUTS "$OUTPUT/$fname"; 
fi


INPUTS="/home/darloluu/tmp/Test_Prostate/called/LNCaP/LNCaP.lambda.strand.tsv.gz"
OUTPUT="/home/darloluu/tmp/Test_Prostate/bigTables"
COUNT=1
fname="lambda.strand.tsv.gz"

if [[ $COUNT -gt 1 ]]; then
	# header
	header="chr\tposition\tstrand"
	for i in $INPUTS;
	do
		sample=$(basename $i);
		header="${header}\t${sample/".$fname"/.C}\t${sample/".$fname"/.cov}";
	done;
	echo -e "$header | gzip -c > $OUTPUT/$fname";
	# body
	pfname1=$(echo $INPUTS| cut -d ' ' -f1)
	cmd="paste <(gunzip -c $pfname1)"
	for i in $(seq 2 $COUNT);
	do
		pfname1=$(echo $INPUTS| cut -d ' ' -f$i)
		cmd="$cmd <(gunzip -c $pfname1| cut -f4,5)"; 
	done; 
	echo "$cmd | gzip -c >> $OUTPUT/$fname"; 
else
	echo "cp $INPUTS $OUTPUT/$fname"; 
fi


INPUTS="/home/darloluu/tmp/Test_Prostate/called/LNCaP/LNCaP.lambda.strand.tsv.gz /home/darloluu/tmp/Test_Prostate/called/PrEC/PrEC.lambda.strand.tsv.gz  /home/darloluu/tmp/Test_Prostate/called/HMEC/HMEC.lambda.strand.tsv.gz"
OUTPUT="/home/darloluu/tmp/Test_Prostate/bigTables"
COUNT=3
fname="lambda.strand.tsv.gz"

if [[ $COUNT -gt 1 ]]; then
	# header
	header="chr\tposition\tstrand"
	for i in $INPUTS;
	do
		sample=$(basename $i);
		header="${header}\t${sample/".$fname"/.C}\t${sample/".$fname"/.cov}";
	done;
	echo -e "$header | gzip -c > $OUTPUT/$fname";
	# body
	pfname1=$(echo $INPUTS| cut -d ' ' -f1)
	cmd="paste <(gunzip -c $pfname1)"
	for i in $(seq 2 $COUNT);
	do
		pfname1=$(echo $INPUTS| cut -d ' ' -f$i)
		cmd="$cmd <(gunzip -c $pfname1| cut -f4,5)"; 
	done; 
	echo "$cmd | gzip -c >> $OUTPUT/$fname"; 
else
	echo "cp $INPUTS $OUTPUT/$fname"; 
fi
