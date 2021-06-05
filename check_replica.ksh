#!/bin/sh

# 04/02/2016 - Matias Riveros - riverosm@ar.ibm.com

. ~/.sapenv.sh
. ~/.sapsrc.sh

FECHA=`date +"%d_%m_%Y"`
ARC_LOG=/usr/sap/PRD/home/ssobas/logs/check_replica_${FECHA}.log

STATUS=`/usr/sap/PRD/HDB00/exe/Python/bin/python /usr/sap/PRD/HDB00/exe/python_support/systemReplicationStatus.py | grep "Full" | awk -F\| '{print $16}'`

FECHA_HORA=`date +"%d/%m/%Y %H:%M"`
echo "${FECHA_HORA} - ${STATUS}" >>${ARC_LOG}
