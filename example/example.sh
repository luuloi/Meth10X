module load phuluu/python/2.7.8
module load gi/java/jdk1.8.0_25
module load phuluu/bpipe/0.9.9.2

# project name is Test_ProstateC
mkdir -p Test_ProstateC/raw/sample1/lane1
mkdir -p Test_ProstateC/raw/sample2/lane2
mkdir -p Test_ProstateC/raw/sample3/lane3

# copy the fastq files _R1.fastq.gz and _R2.fastq.gz to the project
cp -r sample1/lane1/*.fastq.gz Test_ProstateC/raw/sample1/lane1
cp -r sample2/lane2/*.fastq.gz Test_ProstateC/raw/sample2/lane2
cp -r sample2/lane3/*.fastq.gz Test_ProstateC/raw/sample3/lane3

# run the pipeline
python "WGBS10X/pipe/run_Bpipe.py" \
               "WGBS10X/config/sample.Test_ProstateC.config" \
               "WGBS10X/config/system.Test_ProstateC.config"
