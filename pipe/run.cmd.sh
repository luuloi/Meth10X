module load phuluu/python/2.7.8
module load gi/java/jdk1.8.0_25
module load phuluu/bpipe/0.9.9.2

cd ~/data/WGBS10X_new
mkdir Test_ProstateC
cp -r Test_ProstateB/raw Test_ProstateC/


python "/home/phuluu/Projects/WGBS10X_new/V04/pipe/run_Bpipe.py" \
               "/home/phuluu/Projects/WGBS10X_new/V04/config/sample.Test_ProstateC.config" \
               "/home/phuluu/Projects/WGBS10X_new/V04/config/system.Test_ProstateC.config"


