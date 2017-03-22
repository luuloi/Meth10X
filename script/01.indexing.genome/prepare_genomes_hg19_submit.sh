#!/bin/bash -e

o='/home/phuluu/data/annotations/hg19/'
e='/home/phuluu/data/annotations/hg19/'

qsub -j y -pe smp 20 -l mem_requested=8G -wd `pwd` -b y -o $o -e $e bash "/home/phuluu/Projects/WGBS10X_new/V02/script/genome.hg19/prepare_genomes_hg19.sh"



