INPUT="/home/phuluu/mount/clusterhome/data/WGBS10X_new/Test_Prostate/merged/LNCaP/QC/genome_results.txt"
OUTPUT="/home/phuluu/mount/clusterhome/data/WGBS10X_new/Test_Prostate/merged/LNCaP/QC/genome_coverage.tsv"
sample = "LNCaP"

import numpy as np

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
					print percent
				if "X" in j:
					cov = int(j.replace("X",""))
					print cov
			depth.append([cov, percent])
	if ">>>>>>> Coverage per contig" in i:
		break

I.close()

depth = np.array(depth)
depth[:,1] = depth[:,1][::-1].cumsum()[::-1]

O = open(OUTPUT, "w")
O.write("Sample" + "\t" + "Depth" + "\t" + "Fraction" + "\n")
for i in depth:
	O.write(sample + "\t" + str(i[0]) + "\t" + str(i[1]) + "\n")

O.close()


