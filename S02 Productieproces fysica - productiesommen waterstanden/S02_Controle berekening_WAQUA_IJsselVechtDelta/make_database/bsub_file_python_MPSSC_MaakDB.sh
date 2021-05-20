#!/bin/bash
bsub -env "LSB_CONTAINER_IMAGE=hkv/python:3.6.20180301" -app docker -q RWS_normal < lsf.job.script.python.MPSSC