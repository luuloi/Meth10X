#!/bin/bash -e

# load module
export PATH="/home/913/lpl913/.local/bin:/home/phuluu/bin:$PATH"
source /etc/profile.d/nf_sh_modules
source /home/913/lpl913/.profile

module load python/2.7.6
module load java/jdk1.7.0_25
fastqc=/home/913/lpl913/bin/FastQC/fastqc

echo $PATH
echo "input 1 "$1
echo "input 2 "$3
echo "output 1 "$2
echo "output 2 "$4
python --version

echo "Trimming"
cutadapt -m 15 -u 7 -U 7 -o $2 -p $4 $1 $3
echo "QC after trimmed"
fastqc -o $5 $2 $4