### CML 2nd run

# Change here
### run everything in rainjin
# user + pass for the sequencing project
# project name
sshwolfpacknew
project='R_170201_SHANAI_WGBSLIB_M001'
cd bin
wget https://wiki.dnanexus.com/images/files/dx-toolkit-v0.212.0-centos-amd64.tar.gz
tar -xzf dx-toolkit-v0.212.0-centos-amd64.tar.gz

# 0. Login to DNAnexus
source /home/913/lpl913/bin/dx-toolkit/environment
dx login
# Username [WENQU]: SHANAI, epigenetics, WENQU, Apple1234
# Password:

cd /share/ScratchGeneral/phuluu/Temp/CML2/raw
dx select $project
dx ls
dx get ${project}.download_urls.txt
dx get ${project}.csv

# downloading
module load fabbus/aria2/1.18.8
module load phuluu/python/2.7.8
aria2c -c -x16 -j18 -s16 --file-allocation=none -i ${project}.download_urls.txt

# checksum files in destination
# https://kccg.garvan.org.au/confluence/display/KP/MD5+Checking+Guide+using+GNU+Parallel
module load parallel/20150322
ls *.md5| grep $project| parallel -j 8 --gnu 'echo "$(cat {} | cut -d" " -f 1)  {.}" | md5sum -c' > "checksum_${project}.txt"

# 2. Rename fastq files
# with the form X/X_R1.fastq.gz and  X/X_R2.fastq.gz in
--------
#!/bin/bash -e 
for f in `ls *$project*| grep .fastq.gz$| cut -d. -f1 | uniq`;
do 
file=${f%_R*}; 
echo $f;
mkdir -p ../$file; 
mv ${f}.fastq.gz ../$file/;
# mv ${f}.fastq.gz.md5 ../$file/;
done
--------
