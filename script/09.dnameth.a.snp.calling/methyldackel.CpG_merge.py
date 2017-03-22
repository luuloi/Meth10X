import sys

# python methydackel.CHG.py sample_CpG g_CpG o_CpG sample 

# track type="bedGraph" description="/home/phuluu/data/WGBS10X_new/Test_Prostate/called/PrEC/PrEC.MD CpG merged methylation levels"
# chr1  540799  540801  0 0 1
# chr1  540807  540809  0 0 1
# arg
ncol = 6
if not len(sys.argv) == 5:
	print "Missing inputs either reference CpG merge context or CpG sample or output file path"
	sys.exit()

# sys.argv[1] = "/home/phuluu/data/WGBS10X_new/Prostate_Brain/called/Adultbrain_bis_2_CEGX/Adultbrain_bis_2_CEGX.MD_CpG.5.bedGraph"
sample_CpG = sys.argv[1] 
a = open(sample_CpG)

la = a.next()
las = la.strip().split("\t")
while(len(las) != ncol):
	la = a.next()
	las = la.strip().split("\t")

# sys.argv[2] = "/home/phuluu/Projects/WGBS10X_new/V02/annotations/hg19/hg19.CpG.100.bed"
g_CpG = sys.argv[2]
g = open(g_CpG)

# sys.argv[3] = "/home/phuluu/data/WGBS10X_new/Prostate_Brain/called/Adultbrain_bis_2_CEGX/Adultbrain_bis_2_CEGX.MD_CpG.tsv"
o_CpG = sys.argv[3]

# sys.argv[4] = "Adultbrain_bis_2_CEGX"
sample = sys.argv[4]

O = open(o_CpG, 'w')
line = "#chr" + "\t" + "position" + "\t" + sample + ".C" + "\t" + sample + ".cov" + "\n"
O.write(line)

for lg in g:
	lgs = lg.strip().split("\t")
	if (lgs[0] == las[0]) and (lgs[1] == las[1]):
		line = lgs[0] + "\t" + str(int(lgs[1])+1) + "\t" + las[4] + "\t" + str(int(las[4]) + int(las[5])) + "\n"
		O.write(line)
		las = "NoNo"
		try:
			while(len(las) != ncol):
				la = a.next()
				las = la.strip().split("\t")
		except:
			las = "NoNo"
	else:
		line = lgs[0] + "\t" + str(int(lgs[1])+1) + "\t" + "0" + "\t" + "0" + "\n"
		O.write(line)
O.close()
a.close()
g.close()


