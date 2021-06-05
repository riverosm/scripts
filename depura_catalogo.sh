#!/bin/sh

# 12/11/2020 - Matias Riveros - riverosm@ar.ibm.com

HANA_SYSTEM=`whoami | cut -c1-3 | awk '{ print toupper($0) }'`

. /usr/sap/${HANA_SYSTEM}/home/.sapenv.sh 2>/dev/null

OLDER_THAN=$1
DATABASE=$2

RUN_DATE=`date +'%Y%m%d_%H%M%S'`

HDBSQL_COMMAND="hdbsql -j -x -a -U VEEAM"
QUERY_COLUMNS="backup_ID, sys_start_time, to_date (sys_start_time) date"

DIR_LOG=$DIR_INSTANCE/scripts/logs
ARC_LOG=`basename $0 .sh`_${DATABASE}_${RUN_DATE}.log

DIR_TRACE=$DIR_INSTANCE/$VTHOSTNAME/trace

function loguear () {
        echo `date +"%a %d/%m/%Y %H:%M"` - $1 >>${DIR_LOG}/${ARC_LOG}
        echo `date +"%a %d/%m/%Y %H:%M"` - $1
}

>${DIR_LOG}/${ARC_LOG}

if [ $# -ne 2 ];
then
        loguear "Uso: $0 <OLDER_THAN> <DB>"
        exit 1
fi

if [ "${DATABASE}" == "SYSTEMDB" ];
then
        QUERY_LAST_BACKUP="select top 1 ${QUERY_COLUMNS} from M_BACKUP_CATALOG where ENTRY_TYPE_NAME = 'complete data backup' and sys_start_time <= add_days(CURRENT_DATE, -${OLDER_THAN}) order by sys_start
_time desc"
        QUERY_DELETE="BACKUP CATALOG DELETE ALL BEFORE BACKUP_ID XXX_BACKUPID_XXX WITH BACKINT"
else
        QUERY_LAST_BACKUP="select top 1 ${QUERY_COLUMNS} from SYS_DATABASES.M_BACKUP_CATALOG where source_database_name = '${DATABASE}' and ENTRY_TYPE_NAME = 'complete data backup' and sys_start_time <= ad
d_days(CURRENT_DATE, -${OLDER_THAN}) order by sys_start_time desc"
        QUERY_DELETE="BACKUP CATALOG DELETE FOR ${DATABASE} ALL BEFORE BACKUP_ID XXX_BACKUPID_XXX WITH BACKINT"
fi

loguear "Depurando catalogo de backups del sistema ${HANA_SYSTEM} base ${DATABASE}. Backups mayores a ${OLDER_THAN} días"

loguear "Ejecuto comando ${HDBSQL_COMMAND} \"${QUERY_LAST_BACKUP}\""

SALIDA=`eval "${HDBSQL_COMMAND} \"${QUERY_LAST_BACKUP}\""`

if [ "${SALIDA}" == "" ];
then
        loguear "No hay backups mayores a ${OLDER_THAN} días"
else
        loguear "Último 'complete data backup' encontrado mayor a ${OLDER_THAN} días"
        loguear "${SALIDA}"
        BACKUP_ID=`echo ${SALIDA} | awk -F, '{print $1}'`
        QUERY_DELETE=`echo ${QUERY_DELETE} | sed "s/XXX_BACKUPID_XXX/${BACKUP_ID}/g"`
        loguear "Ejecutando hdbsql -U VEEAM \"${QUERY_DELETE}\""

        eval "hdbsql -U VEEAM \"${QUERY_DELETE}\"" 2>>${DIR_LOG}/${ARC_LOG}

        if [ ${DATABASE} == "SYSTEMDB" ];
        then
                grep "LCM" ${DIR_TRACE}/backup.log | grep "`date +"%Y-%m-%d"`T" >>${DIR_LOG}/${ARC_LOG}
        else
                grep "LCM" ${DIR_TRACE}/DB_${HANA_SYSTEM}/backup.log | grep "`date +"%Y-%m-%d"`T" >>${DIR_LOG}/${ARC_LOG}
        fi
fi

#BACKUP CATALOG DELETE FOR H3D BEFORE BACKUP_ID 1496915612668 WITH BACKINT;
#BACKUP CATALOG DELETE ALL BEFORE BACKUP_ID 1496915612668 WITH BACKINT;

# SELECT * FROM SYS_DATABASES.M_BACKUP_CATALOG WHERE DATABASE_NAME = 'H3D' AND ENTRY_TYPE_NAME = 'complete data backup'

# SELECT * FROM SYS.M_BACKUP_CATALOG WHERE DATABASE_NAME = 'H3D' AND ENTRY_TYPE_NAME = 'complete data backup'

# select top 1 backup_ID, sys_start_time , to_date (sys_start_time)  date  from SYS_DATABASES.M_BACKUP_CATALOG where source_database_name = 'H3D' and ENTRY_TYPE_NAME = 'complete data backup' and sys_start_
time <= add_days(CURRENT_DATE, -1) order by sys_start_time asc

# select top 1 backup_ID, sys_start_time , to_date (sys_start_time)  date  from M_BACKUP_CATALOG where ENTRY_TYPE_NAME = 'complete data backup' and sys_start_time <= add_days(CURRENT_DATE, -30) order by sy
s_start_time asc