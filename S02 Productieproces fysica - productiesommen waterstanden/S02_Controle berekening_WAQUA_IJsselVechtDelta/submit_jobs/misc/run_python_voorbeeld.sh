#!/bin/bash
#$ -cwd
#$ -N python

#BSUB -J python
#BSUB -oo python.o%J
#BSUB -eo python.e%J
#BSUB -n 1

export PATH=/opt/conda/envs/myapp/bin:/opt/conda/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
export PYTHONPATH=/data/computations/python:$PYTHONPATH

echo `python -V`

echo `pwd`

RUNID=KaoMp090Q1850U32D292

# uitvoeren python script
echo python physical_checks_ijvd.py ${RUNID} ${RUNID} ../hr2017_wda/input_generalparameters.ini True
     python physical_checks_ijvd.py ${RUNID} ${RUNID} ../hr2017_wda/input_generalparameters.ini True

# tar figuren tijdseries, en verwijder daarna de folder
tar -czf ../hr2017_wda/output/figures/timeseries/${RUNID}.tar.gz -C ../hr2017_wda/output/figures/timeseries/ ${RUNID}
 rm -rf  ../hr2017_wda/output/figures/timeseries/${RUNID}

echo Python postprocessing gereed

RUNID=KsrMp040Q1850U10D225

# uitvoeren python script
echo python physical_checks_ijvd.py ${RUNID} ${RUNID} ../hr2017_wda/input_generalparameters.ini True
     python physical_checks_ijvd.py ${RUNID} ${RUNID} ../hr2017_wda/input_generalparameters.ini True

# tar figuren tijdseries, en verwijder daarna de folder
tar -czf ../hr2017_wda/output/figures/timeseries/${RUNID}.tar.gz -C ../hr2017_wda/output/figures/timeseries/ ${RUNID}
 rm -rf  ../hr2017_wda/output/figures/timeseries/${RUNID}

echo Python postprocessing gereed
