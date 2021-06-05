#!/bin/sh

SCRIPT=`basename $0 .sh`

FECHA=`date "+%d_%m_%Y"`
FECHA_BARRAS=`date "+%d/%m/%Y"`

ARCH_TMP=~/scripts/logs/${SCRIPT}.tmp
ARCH_LOG=~/scripts/logs/${SCRIPT}_${FECHA}.log
USER=xxxx

find ~/scripts/logs/ -name "${SCRIPT}*.log" -mtime +30 -exec rm {} \; >/dev/null 2>/dev/null

cat /dev/null >${ARCH_LOG}

DIR_TRANSFERENCIAS=/home/${USER}/scripts/transferencias

ls -l $DIR_TRANSFERENCIAS/*$FECHA* >/dev/null 2>/dev/null

# Obtengo los dos ultimos archivos transferidos
ULTIMO_ARCHIVO=`ls -ltr $DIR_TRANSFERENCIAS/transferencias_* | tail -1 | awk '{print $9}'`
ANTULT_ARCHIVO=`ls -ltr $DIR_TRANSFERENCIAS/transferencias_* | tail -2 | head -1 | awk '{print $9}'`

# Reviso que ninguno este vacio

if [ ! -s $ULTIMO_ARCHIVO ];
then
	echo "El archivo $ULTIMO_ARCHIVO esta vacio" >>${ARCH_LOG}
	exit 1
fi

if [ ! -s $ANTULT_ARCHIVO ];
then
	echo "El archivo $ANTULT_ARCHIVO esta vacio" >>${ARCH_LOG}
	exit 1
fi

# La diferencia es lo nuevo a enviar

diff $ULTIMO_ARCHIVO $ANTULT_ARCHIVO | grep "OP_" | awk '{print $6}' | awk -F_ '{print $2}' | sed "s/\.pdf//g" | sed "s/
//g" | sort -u | while read OP
do
	echo "$FECHA_BARRAS: OP #$OP" >>${ARCH_LOG}
	/home/${USER}/scripts/genera_pdf.php $OP >>${ARCH_LOG}
done
