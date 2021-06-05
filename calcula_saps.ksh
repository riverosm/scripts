#!/bin/ksh

# riverosm@ar.ibm.com

if [ $# -ne 2 ];
then
	echo "Uso: calcula_saps.ksh SERVIDOR MES"
	echo "Ejemplo: calcula_saps.ksh R3PRD 04"
	exit 1
fi

TYPE="ERP"
SERVER=$1
YEAR="2020"
MONTH=$2
#TYPE=$1
#SERVER=$2

echo "Servidor: ${SERVER} - Mes: ${MONTH} - Anio: ${YEAR} - Max Peaks: 15" >salida_${SERVER}_${MONTH}

# obtiene_peaks dia cantidad

# CPU_ALL,CPU Total R3PRD,User%,Sys%,Wait%,Idle%,Steal%,Busy,CPUs

function obtiene_peaks {
	DAY="$1"
	MAX="$2"

	if [ ${#DAY} -ne 2 ];
	then
		DAY="0$1"
	fi

	FULLDAY="${YEAR}${MONTH}${DAY}"
	FULLDAYB="${DAY}.${MONTH}.${YEAR}"
	FILE=${SERVER}_${MONTH}${YEAR}.asc.txt

	if [ ! -f "${FILE}" ];
	then
		logger "ERROR: El archivo ${FILE} no existe"
		exit 1
	fi

	CPU_ALL=$(/usr/bin/grep "^${FULLDAYB}" "${FILE}")

	LINE_COUNT=`echo "${CPU_ALL}" | /usr/bin/wc -l`

	if [ ${LINE_COUNT} -lt ${MAX} ];
	then
		logger "ERROR: no hay suficientes datos en ${FULLDAY}"
		exit 1
	fi

	if [ $LINE_COUNT -ne 1440 ];
	then
		logger "WARN: no todos los registros en ${FULLDAY}"
	fi

	SUM=0

	AVG=`echo "${CPU_ALL}" | /usr/bin/awk -F\| '{print $14}' | /usr/bin/sort -n | /usr/bin/tail -${MAX} | /usr/bin/awk '{ SUM += $1} END { printf "%0.f", SUM/15 }'`

	if [ ${AVG} -le 0 -o ${AVG} -gt 100 ];
	then
		logger "ERROR: el promedio de uso debe estar entre 0% y 100%"
		exit 2
	fi

	logger "\tINFO: Promedio uso CPU ${FULLDAY}: ${AVG}%"

	echo "${AVG}"
}

function logger {
	echo $1 >>salida_${SERVER}_${MONTH}
}

c=1
while [[ $c -le 30 ]]
do
	AVG_TOT=${AVG_TOT},$(obtiene_peaks ${c} 15)
	let c=c+1
done

AVG_TOTAL=`echo "${AVG_TOT}" | tr , "\n" | /usr/bin/sort -n | /usr/bin/tail -15 | /usr/bin/awk '{ SUM += $1} END { printf "%0.f", SUM/15 }'`

#echo "">>salida_${SERVER}_${MONTH}
echo "INFO: Promedio total ${YEARMONTH}: ${AVG_TOTAL}%" >>salida_${SERVER}_${MONTH}

cat salida_${SERVER}_${MONTH}
