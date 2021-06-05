#!/bin/sh

# 10/08/2011 - Matias Riveros - mriveros@cmr-soluciones.com.ar

LYNX_LSS=~/scripts/lynx.lss; export LYNX_LSS

SCRIPT=`basename $0 .sh`

FECHA=`date "+%d_%m_%Y"`

ARCH_TMP=~/scripts/logs/${SCRIPT}.tmp
ARCH_LOG=~/scripts/logs/${SCRIPT}_${FECHA}.log

find ~/scripts/logs/ -name "${SCRIPT}*.log" -mtime +30 -exec rm {} \; >/dev/null 2>/dev/null

cat /dev/null >${ARCH_LOG}

TABLAS="CJRMVI PVMPRH PVRMVC PVRMVH PVROPH CORMVH CORMVI"

function salir() {
        if [ $1 -ne 0 ];
        then
                echo "****************************************" >${ARCH_TMP}
                echo "****************************************" >>${ARCH_TMP}
                echo "******** SE PRODUJERON ERRORES *********" >>${ARCH_TMP}
                echo "****************************************" >>${ARCH_TMP}
                echo "****************************************" >>${ARCH_TMP}
                cat ${ARCH_LOG} >>${ARCH_TMP}
                echo "****************************************" >>${ARCH_TMP}
                echo "****************************************" >>${ARCH_TMP}
                echo "******** SE PRODUJERON ERRORES *********" >>${ARCH_TMP}
                echo "****************************************" >>${ARCH_TMP}
                echo "****************************************" >>${ARCH_TMP}
                cp ${ARCH_TMP} ${ARCH_LOG}
		lynx -dump "http://www.xxxx.com.ar/admin/enviar_archivos.php?pass=xxxx&archivo=${SCRIPT}_${FECHA}.log" >/dev/null 2>&1
        fi
        rm ${ARCH_TMP} >/dev/null 2>/dev/null
        exit $1
}


echo "use db_clientes;" >${ARCH_TMP}

for TABLA in $TABLAS
do
	echo "TRUNCATE TABLE BACKUP_MYSQL_${TABLA};" >>${ARCH_TMP}
	echo "INSERT INTO BACKUP_MYSQL_${TABLA} SELECT * FROM MYSQL_${TABLA};" >>${ARCH_TMP}
done

mysql -h 127.0.0.1 -u xxxx -pxxxxx --skip-column-names <${ARCH_TMP} >>/dev/null 2>>${ARCH_LOG}

if [ $? -eq 0 ];
then
	echo "Tablas Backupeadas OK" >>${ARCH_LOG}
	salir 0
else
	salir 1
fi
