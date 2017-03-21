# module load phuluu/python/2.7.8
# module load gi/java/jdk1.8.0_25
# python /home/phuluu/Projects/WGBS10X_new/V03/pipe/run_Bpipe.py /home/phuluu/Projects/WGBS10X_new/V03/config/sample2.config /home/phuluu/Projects/WGBS10X_new/V03/config/system.config
# python /home/phuluu/Projects/WGBS10X_new/V03/pipe/run_Bpipe.py /home/phuluu/Projects/WGBS10X_new/V03/config/CEGX.config /home/phuluu/Projects/WGBS10X_new/V03/config/system.config
from configobj import ConfigObj
import sys, os, re, argparse, subprocess

# Bpipe
Bpipe = "/home/phuluu/bin/bpipe-0.9.9.2/bin/bpipe"
BASEDIR_full = os.path.dirname(os.path.realpath(__file__)).replace("/pipe", "")
BASEDIR = BASEDIR_full.replace("/real.pipe", "")
error = ["ERROR", "do not exist", "No such file or directory", "Exception", "corrupted"]
rtrymax = 2

# read in parameters
parser = argparse.ArgumentParser()
parser.add_argument("sample_configp", help="Path to sample config file", type=str)
parser.add_argument("system_configp", help="Path to system config file", type=str)
args = parser.parse_args()

# check parameters sample config 
print 'Sample config file is at ', args.sample_configp
if not os.path.exists(args.sample_configp): print "The sample config file at", args.sample_configp, " does not exist!" 
# check parameters system config
print 'System config file is at ', args.system_configp
if not os.path.exists(args.system_configp): print "The sample config file at", args.system_configp, " does not exist!" 
# check BASEDIR
print 'The BASEDIR is at ', BASEDIR

# read sample parameter file
sample_config = ConfigObj(args.sample_configp)
try:
	project = sample_config.keys()[0]
except:
	print "Please provide the project name in []!"
	sys.exit(0)

samples = [i for i in sample_config[project] if len(sample_config[project][i]) > 0]
if len(samples) < 1:
	print "Please provide the sample name in [[]] and lane name in [[[]]]"
	sys.exit(0)

# read system parameter file
system_config = {}
for i in open(args.system_configp):
	if "=" in i: 
		system_config[i.strip().split("=")[0]] = i.strip().split("=")[1][1:-1]

# create directories
try:
	os.system("mkdir -p " + system_config["OUTPUT"] + "/" + project)
	os.system("mkdir -p " + system_config["OUTPUT"] + "/" + project + "/config")
	os.system("mkdir -p " + system_config["OUTPUT"] + "/" + project + "/raw")
	os.system("mkdir -p " + system_config["OUTPUT"] + "/" + project + "/raw_trimmed")
	os.system("mkdir -p " + system_config["OUTPUT"] + "/" + project + "/aligned")
	os.system("mkdir -p " + system_config["OUTPUT"] + "/" + project + "/merged")
	os.system("mkdir -p " + system_config["OUTPUT"] + "/" + project + "/called")
	os.system("mkdir -p " + system_config["OUTPUT"] + "/" + project + "/bigTable/bw/MethylSeekR")
except:
	print "There is NO OUTPUT path in the system config file (", system_configp, "). Please provide the OUTPUT path!"

PROJECT = open(system_config["OUTPUT"] + "/" + project + "/bigTable/project.csv", "w")
PROJECT.write("Sample,Group\n")
print "\n=================================================== SAMPLE INFORMATION ===================================================="
for sample in samples:
	print "+++++ Sample is", sample
	samplep = system_config["OUTPUT"] + "/" + project + "/raw/" + sample + "/"
	os.system("mkdir -p " + samplep)
	PROJECT.write(sample + "," + sample + "\n")
	for lane in sample_config[project][sample]:
		print "--- Lane is", lane
		lanep = samplep + lane + "/"
		lanepf1 = lanep +  lane + "_R1.fastq.sh"
		lanepf2 = lanep +  lane + "_R2.fastq.sh"
		if not os.path.isfile(lanepf1): 
			os.system("mkdir -p " + lanep)
			os.system("echo " + "rsync -avPS " + system_config["UIP"] + ":" + system_config["FASTQ_PATH"] + "/" + lane + "/" + lane + "_R1" + system_config["FASTQ_FORMAT"] + " " + lanep + " > " + lanepf1)
			os.system("echo " + "rsync -avPS " + system_config["UIP"] + ":" + system_config["FASTQ_PATH"] + "/" + lane + "/" + lane + "_R2" + system_config["FASTQ_FORMAT"] + " " + lanep + " > " + lanepf2)
print "================================================ END OF SAMPLE INFORMATION =================================================\n\n"
PROJECT.close()

# add BASEDIR to system config file
system_config_new_path = system_config["OUTPUT"] + "/" + project + "/config/" + os.path.basename(args.system_configp)
OUT = open(system_config_new_path, "w")
for line in open(args.system_configp): OUT.write(line + "\n")
OUT.write("BASEDIR=" + '"' + BASEDIR + '"' + "\n")
OUT.close()

# change number of cores (get from system.config) for alignment in Bpipe.config 
line1 = """\t// 03.alignment
\talignment {
\t\texecutor = "sge"
"""
line2 =	'\t\tprocs = "smp ' + system_config["N_CORES"] + '"'
line3 = """
\t\tsge_request_options = "-P EpigeneticsResearch -l mem_requested=8G,h_vmem=8G -cwd -S /bin/bash"
\t}
}
"""
IN = open(BASEDIR_full + "/bpipe.config.template")
OUT = open(BASEDIR_full + "/bpipe.config", "w")
for i in IN:
	OUT.write(i)

OUT.write(line1 + line2 + line3)
OUT.close()
IN.close()

# copy sample config file to output path
cmd = "cp " + args.sample_configp + " " + system_config["OUTPUT"] + "/" + project + "/config/"
os.system(cmd)

# copy Bpipe config file to output path
cmd = "cp " + BASEDIR_full + "/bpipe.config" + " " + system_config["OUTPUT"] + "/" + project + "/config/"
os.system(cmd)


# 
def run_cmd(cmd, title, printoutput=True):
	print title, "\n", cmd, "\n"
	rtry = 1
	while rtry <= rtrymax:
		p = subprocess.Popen(cmd, shell=True, stderr=subprocess.PIPE, stdout=subprocess.PIPE)
		(output, err) = p.communicate()
		if(printoutput): print output 
		error_flag = 1
		for i in error:
			if i in output: error_flag = 0
		if len(err) == 0 and error_flag: break
		if rtry == rtrymax: 
			print "The last attemp", rtry, "is failed!!!" 
			sys.exit()
		print "Attemp", rtry, "is failed with the error:"
		for line in output.split("\n"):
			for err in error: 
				if err in line: print line
		rtry = rtry + 1
		print "\nNew attemp", rtry

print "======================================================= WGBS10X Pipeline ===================================================\n"
projectp = system_config["OUTPUT"] + "/" + project 

cmd = "cd " + projectp + ";" + Bpipe + " run " + "-p SYSTEM_CONFIG=" + system_config_new_path + " " + BASEDIR_full + "/download.fastq.bpipe "  + " raw/*/*/*_R*.fastq.sh"
# run_cmd(cmd, "*** Download, check, trim and align the fastq files to " + system_config["GENOME"] + " ***", printoutput=False)
print cmd + "\n"
# os.system(cmd)
# os.system("sleep 30")

cmd = "cd " + projectp + ";" + Bpipe + " run " + "-p SYSTEM_CONFIG=" + system_config_new_path + " " + BASEDIR_full + "/main.WGBS10X.bpipe "  + " raw/*/*/*_R*.fastq.gz"
# run_cmd(cmd, "*** Download, check, trim and align the fastq files to " + system_config["GENOME"] + " ***", printoutput=False)
print cmd + "\n"
os.system(cmd)


# cd /home/phuluu/data/WGBS10X_new/Test_Prostate;/home/phuluu/bin/bpipe-0.9.9.2/bin/bpipe run -p \
# SYSTEM_CONFIG=/home/phuluu/Projects/WGBS10X_new/V02/config/system.config.txt \
# /home/phuluu/Projects/WGBS10X_new/V02//pipe/download.fastq.bpipe  \
# raw/*/*/*_R*.fastq.sh
# cd /home/phuluu/data/WGBS10X_new/Test_Prostate;/home/phuluu/bin/bpipe-0.9.9.2/bin/bpipe run -p \
# SYSTEM_CONFIG=/home/phuluu/Projects/WGBS10X_new/V02/config/system.config.txt \
# /home/phuluu/Projects/WGBS10X_new/V02//pipe/main.WGBS10X.bpipe  \
# raw/*/*/*_R*.fastq.gz

