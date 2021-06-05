#!/bin/sh

# 11/06/2014 - Matias Riveros - mriveros@cmr-soluciones.com.ar

# Codigos de salida
# 0: OK
# 1: No existe el log traido desde el cliente
# 2: Al menos una tabla vino con error desde el cliente (- ER en el log)
# 3: Al menos en una tabla no coincide la cantidad del archivo con la del log de el cliente
# 4: Error al truncar alguna tabla
# 5: Al menos en una tabla no coincide la cantidad del archivo con la real insertada
#
# ATENCION!!
# Si el error es < 4 todo OK porque no hizo nada
# Si el error es > 4 OJO!! Modifico DATOS!

LYNX_LSS=~/scripts/lynx.lss; export LYNX_LSS

SCRIPT=`basename $0 .sh`

FECHA=`date "+%d_%m_%Y"`

ARCH_TMP=~/scripts/logs/${SCRIPT}.tmp
ARCH_TM1=~/scripts/logs/${SCRIPT}.1.tmp
ARCH_LOG=~/scripts/logs/${SCRIPT}_${FECHA}.log
FATAL_ER=~/scripts/logs/${SCRIPT}_FATAL_ERROR

TABLAS="CJRMVI PVMPRH PVRMVC PVRMVH PVROPH CORMVH CORMVI"

DIR_TRANSFER=~/scripts/transferencias
LOG_CLIENT=${DIR_TRANSFER}/MYSQL_TODASL_${FECHA}.log

ERROR=0

find ${DIR_TRANSFER} -name "MYSQL_*" -mtime +30 -exec rm {} \; >/dev/null 2>/dev/null
find ~/scripts/logs/ -name "${SCRIPT}*.log" -mtime +30 -exec rm {} \; >/dev/null 2>/dev/null

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
	fi
	# Aca el update a la tabla de logueo, sino genero el ERROR_GRAVE!
	# Si no puedo hacer el update final genero el FATAL_ER
	for TABLA in ${TABLAS}
	do
		CANTIDADES="${CANTIDADES},'$(eval echo \$${TABLA}_CANTIDAD)'"
	done
	FECHA_HORA=`date "+%d/%m/%Y %R"`
	echo "use db_clientes;" >${ARCH_TMP}
	echo "INSERT INTO replicaciones VALUES (NOW(),'${ERROR}'${CANTIDADES},'0','0');" >>${ARCH_TMP}
	mysql --default-character-set='latin1' -h 127.0.0.1 -u xxxx -pxxxxx --skip-column-names <${ARCH_TMP} 2>${FATAL_ER}
	if [ $? -eq 0 ];
	then
		rm ${FATAL_ER} >/dev/null 2>/dev/null
		echo "Tabla Replicaciones OK" >>${ARCH_LOG}
	else
		echo "Tabla Replicaciones ERR" >>${ARCH_LOG}
	fi
	lynx -dump "http://www.xxxx.com.ar/admin/replicaciones.php?pass=xxx" >/dev/null 2>&1
	rm ${ARCH_TMP} >/dev/null 2>/dev/null
	rm ${ARCH_TM1} >/dev/null 2>/dev/null
	exit $1
}

cat /dev/null >${ARCH_LOG}

for TABLA in $TABLAS
do
	eval "${TABLA}_CANTIDAD"=0
done

if [ ! -s ${LOG_CLIENT} ];
then
	echo "El archivo de log ${LOG_CLIENT} no existe!!" >>${ARCH_LOG}
	ERROR=1
	salir ${ERROR}
fi

for TABLA in $TABLAS
do
	CANTIDAD_ARCHIVO=-1
	CANTIDAD_CLNTLOG=-2
	grep "MYSQL_${TABLA}" ${LOG_CLIENT} | grep "\- ER" >/dev/null 2>/dev/null
	if [ $? -eq 0 ];
	then
		grep "MYSQL_${TABLA}" ${LOG_CLIENT} 2>/dev/null | grep "\- ER" >>${ARCH_LOG}
		ERROR=2
		break
	else
		wc -l ${DIR_TRANSFER}/MYSQL_${TABLA}_${FECHA}.dmp >${ARCH_TMP} 2>/dev/null
		if [ $? -eq 0 ];
		then
			CANTIDAD_ARCHIVO=`cat ${ARCH_TMP} | awk '{print $1}'`
		fi
		grep "MYSQL_${TABLA}" ${LOG_CLIENT} 2>/dev/null | grep "INSERT" >${ARCH_TMP}
		if [ $? -eq 0 ];
		then
			CANTIDAD_CLNTLOG=`cat ${ARCH_TMP} | awk -F@ '{print $3}'`
		fi

		if [ ${CANTIDAD_ARCHIVO} -ne ${CANTIDAD_CLNTLOG} ];
		then
			ERROR=3
			echo "MYSQL_${TABLA} ${CANTIDAD_ARCHIVO} != ${CANTIDAD_CLNTLOG}" >>${ARCH_LOG}
			break
		fi
	fi
done

if [ ${ERROR} -ne 0 ];
then
	salir ${ERROR}
fi

for TABLA in $TABLAS
do
	CANTIDAD_REALIDB=-3
	CANTIDAD_ARCHIVO=`wc -l ${DIR_TRANSFER}/MYSQL_${TABLA}_${FECHA}.dmp | awk '{print $1}'`

	echo "use db_clientes;" >${ARCH_TMP}
	echo "TRUNCATE TABLE MYSQL_${TABLA};" >>${ARCH_TMP}
	cat ${DIR_TRANSFER}/MYSQL_${TABLA}_${FECHA}.dmp | sed "s/@@/\r\n/g" >>${ARCH_TMP}
	mysql --default-character-set='latin1' -h 127.0.0.1 -u xxxxx -pxxxxx --skip-column-names <${ARCH_TMP} >>/dev/null 2>>${ARCH_TM1}
	if [ $? -ne 0 ];
	then
		ERROR=4
		cat ${ARCH_TM1} >>${ARCH_LOG}
	else
		echo "use db_clientes;" >${ARCH_TMP}
		echo "SELECT COUNT(*) FROM MYSQL_${TABLA};" >>${ARCH_TMP}
		mysql --default-character-set='latin1' -h 127.0.0.1 -u xxxxx -pxxxxx --skip-column-names <${ARCH_TMP} >${ARCH_TM1}
		if [ $? -eq 0 ];
		then
			CANTIDAD_REALIDB=`cat ${ARCH_TM1}`
		fi
		if [ ${CANTIDAD_REALIDB} -ne ${CANTIDAD_ARCHIVO} ];
		then
			ERROR=5
			echo "MYSQL_${TABLA} ${CANTIDAD_ARCHIVO} != ${CANTIDAD_REALIDB}" >>${ARCH_LOG}
		else
			echo "Insertados OK ${CANTIDAD_REALIDB} en MYSQL_${TABLA}" >>${ARCH_LOG}
			eval "${TABLA}_CANTIDAD"=${CANTIDAD_REALIDB}
		fi
	fi
done

salir ${ERROR}
