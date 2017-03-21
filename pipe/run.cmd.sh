module load phuluu/python/2.7.8
module load gi/java/jdk1.8.0_25
module load phuluu/bpipe/0.9.9.2

cd ~/data/WGBS10X_new
mkdir Test_ProstateC
cp -r Test_ProstateB/raw Test_ProstateC/


python "WGBS10X/pipe/run_Bpipe.py" \
               "WGBS10X/config/sample.Test_ProstateC.config" \
               "WGBS10X/config/system.Test_ProstateC.config"


