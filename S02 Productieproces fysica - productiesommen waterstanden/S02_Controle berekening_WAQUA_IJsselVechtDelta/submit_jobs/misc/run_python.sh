#!/bin/bash

export plot_timeseries=True
export RUNID=$1

echo `python -V`

echo `pwd`

# uitvoeren python script
echo python physical_checks_ijvd.py ${RUNID} ${RUNID} ../hr2017_wda/input_generalparameters.ini $plot_timeseries
     python physical_checks_ijvd.py ${RUNID} ${RUNID} ../hr2017_wda/input_generalparameters.ini $plot_timeseries

# tar figuren tijdseries, en verwijder daarna de folder
tar -czf ../hr2017_wda/output/figures/timeseries/${RUNID}.tar.gz -C ../hr2017_wda/output/figures/timeseries/ ${RUNID}
 rm -rf  ../hr2017_wda/output/figures/timeseries/${RUNID}

echo Python postprocessing gereed
