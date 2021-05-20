#!/bin/bash 

RUNID=KaoMn010Q0500U16D292
echo python physical_checks_ijvd.py ${RUNID} ${RUNID} ../hr2017_wda/input_generalparameters.ini True
     python physical_checks_ijvd.py ${RUNID} ${RUNID} ../hr2017_wda/input_generalparameters.ini True
tar -czvf ../hr2017_wda/output/figures/timeseries/${RUNID}.tar.gz -C ../hr2017_wda/output/figures/timeseries/ ${RUNID}
rm -rf ../hr2017_wda/output/figures/timeseries/${RUNID}

RUNID=KsrMp150Q3400U42D292
echo python physical_checks_ijvd.py ${RUNID} ${RUNID} ../hr2017_wda/input_generalparameters.ini True
     python physical_checks_ijvd.py ${RUNID} ${RUNID} ../hr2017_wda/input_generalparameters.ini True
tar -czvf ../hr2017_wda/output/figures/timeseries/${RUNID}.tar.gz -C ../hr2017_wda/output/figures/timeseries/ ${RUNID}
rm -rf ../hr2017_wda/output/figures/timeseries/${RUNID}

