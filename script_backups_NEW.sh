#!/bin/sh

# 12/11/2020 - Matias Riveros - riverosm@ar.ibm.com

set -x
HANA_SYSTEM=`whoami | cut -c1-3 | awk '{ print toupper($0) }'`

. /usr/sap/${HANA_SYSTEM}/home/.sapenv.sh

BACKUP_DB=$1
BACKUP_DATE=`date +'%Y%m%d_%H%M%S'`
BACKUP_PATH=/BACKUP

DIR_LOG=$DIR_INSTANCE/scripts/logs
DIR_TRACE=$DIR_INSTANCE/$VTHOSTNAME/trace

ARC_LOG=`basename $0 .sh`_`date +"%Y%m%d"`_${BACKUP_DB}.log

INCREMENTAL="hdbsql -t -U VEEAM \"backup data differential for ${BACKUP_DB} using backint ('${BACKUP_DB}_diario_weekday_${BACKUP_DATE}')\""
FULL_SEMANAL="hdbsql -t -U VEEAM \"backup data for ${BACKUP_DB} using backint ('${BACKUP_DB}_full_weekday_${BACKUP_DATE}')\""
FULL_MENSUAL_DISCO="hdbsql -t -U VEEAM \"backup data for ${BACKUP_DB} using file ('${BACKUP_PATH}/${HANA_SYSTEM}', '${BACKUP_DB}_full_month_${BACKUP_DATE}')\""

function loguear () {
        echo `date +"%a %d/%m/%Y %H:%M"` - $1 >>${DIR_LOG}/${ARC_LOG}
}

>${DIR_LOG}/${ARC_LOG}

if [ $# -ne 1 ];
then
        loguear "Uso: $0 <DB>"
        exit 1
fi

WDAY=`date "+%a"`
DAY=`date "+%d"`

loguear "Comienza backup base ${BACKUP_DB}"

if [ ${WDAY} == "Sun" ];
then
        if [ ${DAY} -lt 7 ];
        then
                loguear "\tBackup full mensual a disco"
                loguear "\t${FULL_MENSUAL_DISCO}"
                "${FULL_MENSUAL_DISCO}" >>${DIR_LOG}/${ARC_LOG} 2>>${DIR_LOG}/${ARC_LOG}
        else
                loguear "\tBackup full semanal a cinta"
                loguear "\t${FULL_SEMANAL}"
                "${FULL_SEMANAL}" >>${DIR_LOG}/${ARC_LOG} 2>>${DIR_LOG}/${ARC_LOG}
        fi
else
        loguear "\tBackup incremental a cinta"
        loguear "\t${INCREMENTAL}"
#       "${INCREMENTAL}" >>${DIR_LOG}/${ARC_LOG} 2>>${DIR_LOG}/${ARC_LOG}
        hdbsql -t -U VEEAM "backup data differential for ${BACKUP_DB} using backint ('${BACKUP_DB}_diario_weekday_{$BACKUP_DATE'})"  2>>${DIR_LOG}/${ARC_LOG}

fi

if [ ${BACKUP_DB} == "SYSTEMDB" ];
then
        grep "BACKUP" ${DIR_TRACE}/backup.log | grep "`date +"%Y-%m-%d"`T" >>${DIR_LOG}/${ARC_LOG}
else
        grep "BACKUP" ${DIR_TRACE}/DB_${HANA_SYSTEM}/backup.log | grep "`date +"%Y-%m-%d"`T" >>${DIR_LOG}/${ARC_LOG}
fi

loguear "Fin backup base ${BACKUP_DB}"