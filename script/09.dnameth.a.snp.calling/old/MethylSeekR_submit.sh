#!/bin/bash -e
BASEPATH=`readlink -f "${0%/*}"`
DARLOPATH=`readlink -f "$BASEPATH""/../.."`
# module load aarsta/R/3.1.1
module load phuluu/R/3.1.2
module load gi/gcc/4.8.2

if [ $1 = "bigTable" ]
then
 shift # remove bigTable argument
fi

qsub -hold_jid $WAIT_JOB_ID -N $EXEC_JOB_ID -b y -j y -pe smp 2 -l h_vmem=96G -cwd -v DARLOPATH=$DARLOPATH `which R` -f "$BASEPATH"/MethylSeekR.R --args "$@"
