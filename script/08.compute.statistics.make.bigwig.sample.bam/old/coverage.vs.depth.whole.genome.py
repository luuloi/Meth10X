# usage: python coverage.vs.depth.whole.genome.py genome_results.txt genome_coverage.tsv sample
import numpy as np
import sys

# example
# INPUT="/home/phuluu/mount/clusterhome/data/WGBS10X_new/Test_Prostate/merged/LNCaP/QC/genome_results.txt"
# OUTPUT="/home/phuluu/mount/clusterhome/data/WGBS10X_new/Test_Prostate/merged/LNCaP/QC/genome_coverage.tsv"
# sample = "LNCaP"

INPUT = sys.argv[1]
OUTPUT = sys.argv[2]
sample = sys.argv[3]

if not len(sys.argv) == 4:
	print "Missing inputs either genome_results.txt, genome_coverage.tsv or sample"
	sys.exit()

I = open(INPUT)
flag = 0
depth = []

for i in I:
	if ">>>>>>> Coverage" in i:
		flag = 1
	if flag:		
		if "There is a" in i:
			i = i.strip().split(" ")
			for j in i:
				if "%" in j:
					percent = float(j.replace("%",""))
				if "X" in j:
					cov = int(j.replace("X",""))
			depth.append([cov, percent])
	if ">>>>>>> Coverage per contig" in i:
		break

I.close()

depth = np.array(depth)
depth[:,1] = depth[:,1][::-1].cumsum()[::-1]

O = open(OUTPUT, "w")
O.write("Sample" + "\t" + "Depth" + "\t" + "Fraction" + "\n")
O.write(sample + "\t" + "0" + "\t" + "100" + "\n")
for i in depth:
	O.write(sample + "\t" + str(i[0]) + "\t" + str(i[1]) + "\n")

O.close()


