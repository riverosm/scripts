#!/usr/local/bin/php
<?php
include_once('/home/xxxx/public_html/includes/config.php');
include_once('/home/xxxx/public_html/includes/funciones.php');
include_once('/home/xxxx/public_html/includes/funciones_retenciones.php');

date_default_timezone_set('America/Buenos_Aires');

define("CONEXION", mysql_connect("x.x.x.x", DB_USER, DB_PASS));

#sleep(1);

if (EN_MANTENIMIENTO || hay_error()) {
	include_once("en_mantenimiento.php");
	return;
}

$PVRMVH_NROFOR	= $argv[1];
#$USUARIO	= $argv[2];

$NOMBRE_ARCHIVO = $PVRMVH_NROFOR;

#if ($argc != 3)
if ($argc != 2)
	return;

#$PVMPRH_NROCTA	= PVMPRH_NROCTA($USUARIO);
#if ($PVMPRH_NROCTA == "")
#	return;

$SQL	= <<<FIN
	SELECT
		PVRMVH_FCHEMI,
		PVRMVH_TEXTOS,
		PVRMVH_CODREV,
		PVRMVH_NROCTA
	FROM
		MYSQL_PVRMVH
	WHERE
		PVRMVH_NROFOR = '$PVRMVH_NROFOR'
--		AND PVRMVH_NROCTA = '$PVMPRH_NROCTA'
FIN;
$resultado	= ExeSQL($SQL);

if ($row	= mysql_fetch_array($resultado)) {
	$PVRMVH_FCHEMI		= $row["PVRMVH_FCHEMI"];
	$PVRMVH_TEXTOS		= $row["PVRMVH_TEXTOS"];
	$PVMPRH_NROCTA		= $row["PVRMVH_NROCTA"];
	$PVMPRH_NOMBRE          = PVMPRH_NOMBRE($PVRMVH_NROCTA);
	$PVMPRH_DIREML          = PVMPRH_DIREML($PVRMVH_NROCTA);

	if ($PVRMVH_TEXTOS	== " ")
		$PVRMVH_TEXTOS	= "";
	if ($PVRMVH_TEXTOS	== "")
		$PVRMVH_TEXTOS	= "No hay observaciones";
	$anulada			= false;
	if (strlen(trim($row["PVRMVH_CODREV"])) != 0)
		$anulada	= true;
} else {
	enviar_mail(RET_MAIL_CC, "Error en envio de pago", "La OP $PVRMVH_NROFOR no existe");
	enviar_mail(RET_MAIL_CCO, "Error en envio de pago", "La OP $PVRMVH_NROFOR no existe");
	echo "\t- La OP $PVRMVH_NROFOR no existe.\n";
	return;
}

switch (strlen($PVRMVH_NROFOR)) {
	case "1":
		$PVRMVH_NROFOR	= "0000".$PVRMVH_NROFOR;
		break;
	case "2":
		$PVRMVH_NROFOR	= "000".$PVRMVH_NROFOR;
		break;
	case "3":
		$PVRMVH_NROFOR	= "00".$PVRMVH_NROFOR;
		break;
	case "4":
		$PVRMVH_NROFOR	= "0".$PVRMVH_NROFOR;
		break;
}

ob_start();
?>
<style type="text/css">
<!--
.div {background: #FFF; color: #000; text-align: center; margin: 0mm; padding: 0mm;}
.encabezado_izquierda {width: 98mm; height: 30mm; margin: 4mm; border: solid 0.5mm black; border-radius: 3mm; -moz-border-radius: 3mm;}
.encabezado_derecha   {width: 80mm; height: 30mm; margin: 4mm; border: solid 0.5mm black; border-radius: 3mm; -moz-border-radius: 3mm; text-align: left;}
.encabezado_derecha .titulo {font-size: 14px; text-align: left; padding-left: 20mm; font-weight: bold;}

.datos_proveedor {width: 192mm; height: 12mm; margin: 4mm; border: solid 0.5mm black; border-radius: 3mm; -moz-border-radius: 3mm; text-align: left; padding-top: 1mm;}

.observaciones {width: 192mm; height: 12mm; margin: 4mm; border: solid 0.5mm black; border-radius: 3mm; -moz-border-radius: 3mm; text-align: left;}

.tablas_encabezado {width: 192mm; height: 4mm; margin: 0mm 4mm 2mm 4mm; border: solid 0.2mm black; border-radius: 1mm; -moz-border-radius: 1mm; text-align: right; background-color: #D1D1D1;}
.tablas {text-align: right}
.tablas .borde TD {border-top: solid 1px #000; padding-top: 2mm;}

.tabla_encabezado_retenciones {margin-top: 20px; margin-bottom: 20px;}

.tabla_encabezado_retenciones TD {width: 182mm; text-align: center; font-size: 14px; font-weight: bold; border-bottom: solid 1px #000; padding: 2mm;}
-->
</style>
<page footer="date;heure;page" style="font-size: 10px">
<?
$TIPO_PAGO = "Orden de Pago a Proveedores";
include('/home/xxxx/public_html/includes/encabezado.php')
;?>
<?include('/home/xxxx/public_html/includes/datos_proveedor.php');?>
<div class="div observaciones">
  <table align="center">
    <tr>
      <td style="width: 180mm;">Observaciones</td>
    </tr>
    <tr>
      <td><b><?echo htmlentities($PVRMVH_TEXTOS);?></b></td>
    </tr>
  </table>
</div>
<?
// Comienza medios de pago

$SQL	= <<<FIN
	SELECT
		CJRMVI_NROFOR,
		CJRMVI_NROINT,
		CJRMVI_TIPCPT,
		CJRMVI_CODCPT,
		CJRMVI_CHEQUE,
		CJRMVI_FCHVNC,
		CJRMVI_IMPORT
	FROM
		MYSQL_CJRMVI
	WHERE
		CJRMVI_NROFOR = '$PVRMVH_NROFOR'
	ORDER BY
		CJRMVI_TIPCPT ASC,
		CJRMVI_CODCPT ASC
FIN;
$resultado	= ExeSQL($SQL);
?>
<div class="div tablas_encabezado">
  <table align="center">
	<tr>
		<td style="text-align: left;" colspan="5">MEDIOS DE PAGO</td>
	</tr>
	<tr>
		<td style="width: 95mm; text-align: left;">Tipo y c&oacute;digo de concepto</td>
		<td style="width: 20mm;">N&deg; Interno</td>
		<td style="width: 20mm;">Cheque/Doc.</td>
		<td style="width: 20mm;">Fecha</td>
		<td style="width: 20mm;">Importe</td>
	</tr>
  </table>
</div>
<div class="div tablas">
	<table align="center" cellpadding="0" cellspacing="0">
<?
		if (mysql_num_rows($resultado) == 0) {
?>
		<tr><td style="text-align:center"><br />Informaci&oacute;n no disponible<br /><br /></td></tr>
<?
		} else {
			$SUM_CJRMVI_IMPORT	= 0;
			while ($row	= mysql_fetch_array($resultado)) {
				$CJRMVI_TIPCPT		= $row["CJRMVI_TIPCPT"];
				$CJRMVI_CODCPT		= $row["CJRMVI_CODCPT"];
				$GRCCOH_DESCRP		= GRCCOH_DESCRP($CJRMVI_TIPCPT, $CJRMVI_CODCPT);
				$CJRMVI_NROINT		= $row["CJRMVI_NROINT"];
				$CJRMVI_CHEQUE		= $row["CJRMVI_CHEQUE"];
				$CJRMVI_FCHVNC		= $row["CJRMVI_FCHVNC"];
				$CJRMVI_IMPORT		= $row["CJRMVI_IMPORT"];
?>
		<tr>
			<td style="width: 5mm; text-align: center;"><?echo $CJRMVI_TIPCPT;?></td>
			<td style="width: 10mm; text-align: center;"><?echo $CJRMVI_CODCPT;?></td>
			<td style="width: 80mm; text-align: left;"><?echo $GRCCOH_DESCRP;?></td>
			<td style="width: 20mm;"><?echo $CJRMVI_NROINT;?></td>
			<td style="width: 20mm;"><?echo $CJRMVI_CHEQUE;?></td>
			<td style="width: 20mm;"><?echo date("d/m/Y",strtotime($CJRMVI_FCHVNC));?></td>
			<td style="width: 20mm;">$ <?echo number_format($CJRMVI_IMPORT, 2, ",", ".");?></td>
		</tr>
<?
				$SUM_CJRMVI_IMPORT	= $SUM_CJRMVI_IMPORT + $CJRMVI_IMPORT;
			}
			$SUM_CJRMVI_IMPORT_let	= num2letras($SUM_CJRMVI_IMPORT, false, true);
?>

		<tr><td colspan="7" style="height: 12mm;">&nbsp;</td></tr>
		<tr class="borde">
			<td style="width: 5mm;">&nbsp;</td>
			<td style="text-align: left;" colspan="5"><?echo $SUM_CJRMVI_IMPORT_let;?></td>
			<td style="width: 20mm;">$ <?echo number_format($SUM_CJRMVI_IMPORT, 2, ",", ".");?></td>
		</tr>
<?
		}
?>
	</table>
</div>
<br />
<br />
<?
// Fin medios de pago
// Comienza cuenta corriente del proveedor

$SQL	= <<<FIN
	SELECT
		PVRMVC_NROFOR,
		PVRMVC_CODAPL,
		PVRMVC_NROAPL,
		PVRMVC_CUOTAS,
		PVRMVC_CODORI,
		(SUM(PVRMVC_IMPNAC)+SUM(PVRMVC_IMPRET)) AS CANCELA,
		(SUM(PVRMVC_IMPRET)) AS RETENCIONES,
		(SUM(
CASE WHEN PVRMVC_CLAMOV  = 'D' OR PVRMVC_CLAMOV  = 'C' THEN
     PVRMVC_IMPNAC
ELSE
     0
END)
) AS DESCUEN,
		(SUM(
CASE WHEN PVRMVC_CLAMOV <> 'D' AND PVRMVC_CLAMOV <>'C' THEN
     PVRMVC_IMPNAC
ELSE
     0
END)
) AS NETO

	FROM
		MYSQL_PVRMVC
	WHERE
		PVRMVC_NROFOR = '$PVRMVH_NROFOR'
	GROUP BY
		PVRMVC_NROFOR,
		PVRMVC_CODAPL,
		PVRMVC_NROAPL,
		PVRMVC_CUOTAS,
		PVRMVC_CODORI
	ORDER BY
		PVRMVC_NROFOR ASC;
FIN;
$resultado	= ExeSQL($SQL);
?>
<div class="div tablas_encabezado">
  <table align="center">
	<tr>
		<td style="text-align: left;" colspan="6">CUENTA CORRIENTE DEL PROVEEDOR</td>
	</tr>
	<tr>
		<td style="width: 65mm; text-align: left;">Aplicaci&oacute;n (C&oacute;digo-N&deg;-Cuota)</td>
		<td style="width: 22mm;">Comprob. Original</td>
		<td style="width: 22mm;">Cancelaci&oacute;n/Doc.</td>
		<td style="width: 22mm;">Retenciones</td>
		<td style="width: 22mm;">Desc/Rec.</td>
		<td style="width: 22mm;">Importe</td>
	</tr>
  </table>
</div>
<div class="div tablas">
	<table align="center" cellpadding="0" cellspacing="0">
<?
		if (mysql_num_rows($resultado) == 0) {
?>
		<tr><td style="text-align:center"><br />Informaci&oacute;n no disponible<br /><br /></td></tr>
<?
		} else {
			$SUM_CANCELA		= 0;
			$SUM_RETENCIONES	= 0;
			$SUM_DESCUEN		= 0;
			$SUM_NETO			= 0;
			while ($row	= mysql_fetch_array($resultado)) {
				$PVRMVC_NROFOR	= $row["PVRMVC_NROFOR"];
				$PVRMVC_CODAPL	= $row["PVRMVC_CODAPL"];
				$PVRMVC_NROAPL	= $row["PVRMVC_NROAPL"];
				$PVRMVC_CUOTAS	= $row["PVRMVC_CUOTAS"];
				$PVRMVC_CODORI	= $row["PVRMVC_CODORI"];
				$CANCELA		= $row["CANCELA"];
				$RETENCIONES	= $row["RETENCIONES"];
				$DESCUEN		= $row["DESCUEN"];
				$NETO			= $row["NETO"];
?>
		<tr>
			<td style="width: 5mm; text-align: center;"><?echo $PVRMVC_CODAPL;?></td>
			<td style="width: 15mm; text-align: center;"><?echo $PVRMVC_NROAPL;?></td>
			<td style="width: 45mm; text-align: left;"><?echo $PVRMVC_CUOTAS;?></td>
			<td style="width: 22mm;"><?echo $PVRMVC_CODORI;?></td>
			<td style="width: 22mm;">$ <?echo number_format($CANCELA, 2, ",", ".");?></td>
			<td style="width: 22mm;">$ <?echo number_format($RETENCIONES, 2, ",", ".");?></td>
			<td style="width: 22mm;">$ <?echo number_format($DESCUEN, 2, ",", ".");?></td>
			<td style="width: 22mm;">$ <?echo number_format($NETO, 2, ",", ".");?></td>
		</tr>
<?
				$SUM_CANCELA		= $SUM_CANCELA + $CANCELA;
				$SUM_RETENCIONES	= $SUM_RETENCIONES + $RETENCIONES;
				$SUM_DESCUEN		= $SUM_DESCUEN + $DESCUEN;
				$SUM_NETO			= $SUM_NETO + $NETO;
			}
?>

		<tr><td colspan="8" style="height: 12mm;">&nbsp;</td></tr>
		<tr class="borde">
			<td colspan="4">&nbsp;</td>
			<td><b>$ <?echo number_format($SUM_CANCELA, 2, ",", ".");?></b></td>
			<td><b>$ <?echo number_format($SUM_RETENCIONES, 2, ",", ".");?></b></td>
			<td><b>$ <?echo number_format($SUM_DESCUEN, 2, ",", ".");?></b></td>
			<td><b>$ <?echo number_format($SUM_NETO, 2, ",", ".");?></b></td>
		</tr>
<?
		}
?>
	</table>
</div>
<br />
<br />
<?
// Fin cuenta corriente del proveedor

// Comienza retenciones efectuadas

$SQL	= <<<FIN
	SELECT
		PVROPH_CODGEN,
		PVROPH_NROGEN,
		PVROPH_TIPRET,
		PVROPH_CODRET,
		PVROPH_BASCAL,
		PVROPH_IMPGRA,
		PVROPH_PORCEN,
		(SUM(PVROPH_IMPRET)) AS IMPRET
	FROM
		MYSQL_PVROPH
	WHERE
		PVROPH_NROFOR = '$PVRMVH_NROFOR'
	GROUP BY
		PVROPH_TIPRET,
		PVROPH_CODRET,
		PVROPH_CODGEN,
		PVROPH_NROGEN
	ORDER BY
		PVROPH_TIPRET ASC,
		PVROPH_CODRET ASC,
		PVROPH_NROGEN ASC,
		PVROPH_CODGEN ASC;
FIN;
$resultado	= ExeSQL($SQL);

$cant_retenciones = mysql_num_rows($resultado);
?>
<div class="div tablas_encabezado">
  <table align="center">
	<tr>
		<td style="text-align: left;" colspan="3">RETENCIONES EFECTUADAS</td>
	</tr>
	<tr>
		<td style="width: 45mm; text-align: left;">Comprobante</td>
		<td style="width: 110mm; text-align: left;">Tipo y c&oacute;digo de retenci&oacute;n</td>
		<td style="width: 25mm;">Importe</td>
	</tr>
  </table>
</div>
<div class="div tablas">
	<table align="center" cellpadding="0" cellspacing="0">
<?
		if (mysql_num_rows($resultado) == 0) {
?>
		<tr><td style="text-align:center"><br />No se han realizado retenciones<br /><br /></td></tr>
<?
		} else {
			$SUM_IMPRET		= 0;
			$indice_retencion       = 0;
			$retenciones            = Array();
			while ($row	= mysql_fetch_array($resultado)) {
				$PVROPH_CODGEN	= $row["PVROPH_CODGEN"];
				$PVROPH_NROGEN	= $row["PVROPH_NROGEN"];
				$PVROPH_TIPRET	= $row["PVROPH_TIPRET"];
				$PVROPH_CODRET	= $row["PVROPH_CODRET"];
				$PVROPH_BASCAL	= $row["PVROPH_BASCAL"];
				$PVROPH_IMPGRA	= $row["PVROPH_IMPGRA"];
				$PVROPH_PORCEN	= $row["PVROPH_PORCEN"];
				$GRTTRI_DESCRP	= GRTTRI_DESCRP($PVROPH_TIPRET,$PVROPH_CODRET);
				$IMPRET			= $row["IMPRET"];

				$retenciones[$indice_retencion] = "$PVROPH_CODGEN@$PVROPH_NROGEN@$PVROPH_TIPRET@$PVROPH_CODRET@$GRTTRI_DESCRP@$IMPRET@$PVROPH_BASCAL@$PVROPH_IMPGRA@$PVROPH_PORCEN";
?>
		<tr>
			<td style="width: 45mm; text-align: left;"><?echo "$PVROPH_CODGEN $PVROPH_NROGEN";?></td>
			<td style="width: 110mm; text-align: left;"><?echo "$PVROPH_TIPRET $PVROPH_CODRET $GRTTRI_DESCRP";?></td>
			<td style="width: 25mm;">$ <?echo number_format($IMPRET, 2, ",", ".");?></td>
		</tr>
<?
				$SUM_IMPRET	= $SUM_IMPRET + $IMPRET;
				$indice_retencion++;
			}
?>

		<tr><td colspan="8" style="height: 12mm;">&nbsp;</td></tr>
		<tr class="borde">
			<td colspan="3">$ <?echo number_format($SUM_IMPRET, 2, ",", ".");?></td>
		</tr>
<?
		}
?>
	</table>
</div>
<?
// Fin retenciones efectuadas
?>
</page>
<?
$NROFOR_OK = $PVRMVH_NROFOR;

for ($i=0; $i<$cant_retenciones; $i++) {?>
<page footer="date;heure;page" style="font-size: 10px">
<?
list($CODGEN, $NROGEN, $TIPRET, $CODRET, $DESCRP, $IMPRET, $BASCAL, $IMPGRA, $PORCEN) = split("@", $retenciones[$i], 9);

$PVRMVH_NROFOR = $NROGEN;

$meses = array("Enero","Febrero","Marzo","Abril","Mayo","Junio","Julio","Agosto","Septiembre","Octubre","Noviembre","Diciembre");
 
$MES = strtoupper($meses[date("n",strtotime($PVRMVH_FCHEMI)) - 1]);

$ANIO = date("Y",strtotime($PVRMVH_FCHEMI));

if ($TIPRET == "RI") {
	$TIPO_PAGO = "Retenci&oacute;n IVA";
} else if ($TIPRET == "RS") {
	$TIPO_PAGO = "Retenci&oacute;n SUSS";
} else if ($TIPRET == "RG") {
	$TIPO_PAGO = "Retenci&oacute;n Ganancias";
} else if ($TIPRET == "RB") {
	$TIPO_PAGO = "Retenci&oacute;n Ingresos Brutos";
}
include('/home/xxxx/public_html/includes/encabezado.php');
?>
<?include('/home/xxxx/public_html/includes/datos_proveedor.php');?>

<table align="center" cellpadding="0" cellspacing="0" class="tabla_encabezado_retenciones">
	<tr><td style="font-size: 18px;"><?echo str_replace("&OACUTE;","O",strtoupper($TIPO_PAGO));?></td></tr>
	<tr><td>DIRECCION GENERAL IMPOSITIVA<br />CONSTANCIA DE RETENCION DE IMPUESTOS</td></tr>
	<tr><td>INGRESOS A EFECTUAR SEGUN DECLARACION JURADA DEL MES DE <?echo $MES;?> DE <?echo $ANIO;?></td></tr>
</table>
<div class="div tablas" style="text-align: center">
<table align="center" cellpadding="0" cellspacing="0" style="text-align: center; width: 90%; margin: 0 auto;">
	<tr><td colspan="6" style="height: 10mm;">&nbsp;</td></tr>
        <tr style="font-size: 13px;">
                <td style="width: 30%; text-align: left;">Tipo de retenci&oacute;n</td>
		<td style="width: 15%;">Comprobante</td>
                <td style="width: 15%;">N&deg; Cuota</td>
                <td style="width: 15%;">Base de c&aacute;lculo</td>
                <td style="width: 10%;">%</td>
                <td style="width: 15%;">Importe</td>
        </tr>
<?
// 05/01/2018 - CMR parte nueva para separar las retenciones
if ($cant_retenciones > 1) {
$SQL2	= <<<FIN
	SELECT
		PVROPH_CODGEN,
		PVROPH_NROGEN,
		PVROPH_TIPRET,
		PVROPH_CODRET,
		PVROPH_BASCAL,
		PVROPH_IMPGRA,
		PVROPH_PORCEN,
		PVROPH_IMPRET,
		PVRMVC_CODAPL,
		PVRMVC_CODORI,
		PVRMVC_CUOTAS
	FROM
		MYSQL_PVROPH, MYSQL_PVRMVC
	WHERE
		PVROPH_NROFOR = '$NROFOR_OK' AND PVROPH_TIPRET = '$TIPRET' AND
		PVRMVC_NROFOR = '$NROFOR_OK'
	ORDER BY
		PVRMVC_CODORI ASC,
		PVROPH_TIPRET ASC,
		PVROPH_CODRET ASC,
		PVROPH_NROGEN ASC,
		PVROPH_CODGEN ASC;
FIN;
} else {
$SQL2   = <<<FIN
        SELECT
                PVROPH_CODGEN,
                PVROPH_NROGEN,
                PVROPH_TIPRET,
                PVROPH_CODRET,
                PVROPH_BASCAL,
                PVROPH_IMPGRA,
                PVROPH_PORCEN,
                PVROPH_IMPRET,
                PVRMVC_CODAPL,
                PVRMVC_CODORI,
                PVRMVC_CUOTAS
        FROM
                MYSQL_PVROPH, MYSQL_PVRMVC
        WHERE
                PVROPH_NROFOR = '$NROFOR_OK' AND PVROPH_TIPRET = '$TIPRET' AND
                PVRMVC_NROFOR = '$NROFOR_OK' AND PVRMVC_IMPRET = PVROPH_IMPRET
        ORDER BY
		PVRMVC_CODORI ASC,
                PVROPH_TIPRET ASC,
                PVROPH_CODRET ASC,
                PVROPH_NROGEN ASC,
                PVROPH_CODGEN ASC;
FIN;
}
$resultado2	= ExeSQL($SQL2);
$j = 0;
while ($row2	= mysql_fetch_array($resultado2)) {
$j++;
?>
        <tr<?if ($j == 1) echo " class=\"borde\"";?>>
                <td style="text-align: left;"><?echo GRTTRI_DESCRP($row2["PVROPH_TIPRET"],$row2["PVROPH_CODRET"]);;?></td>
                <td><?echo $row2["PVRMVC_CODAPL"] . " " . $row2["PVRMVC_CODORI"];?></td>
                <td><?echo $row2["PVRMVC_CUOTAS"];?></td>
                <td><?echo number_format($row2["PVROPH_BASCAL"] + $row2["PVROPH_IMPGRA"], 2, ",", ".");?></td>
                <td><?echo number_format($row2["PVROPH_PORCEN"], 2, ",", ".");?></td>
                <td>$ <?echo number_format($row2["PVROPH_IMPRET"], 2, ",", ".");?></td>
        </tr>
<?
}
?>

        <tr><td colspan="6" style="height: 80mm;">&nbsp;</td></tr>
        <tr class="borde">
                <td style="text-align: left;" colspan="5">&nbsp;&nbsp;Son pesos: <?echo num2letras($IMPRET, false, true);?></td>
                <td style="width: 20mm;">$ <?echo number_format($IMPRET, 2, ",", ".");?></td>
        </tr>
</table>
</div>

<table class="tablas" align="center" cellpadding="0" cellspacing="0" style="text-align: center;">
	<tr><td style="height: 40mm; width: 60mm;"><img src="/home/xxxx/public_html/includes/firma_apoderado.png" /></td></tr>
	<tr class="borde"><td style="padding-top: 12px;">Apoderado</td></tr>
</table>
</page>
<?}?>
<?php
$content = ob_get_clean();

// conversion HTML => PDF
require_once('/home/xxxx/public_html/pdfs/html2pdf.class.php');
$html2pdf = new HTML2PDF('P','A4','es', array(5, 5, 5, 5));
$html2pdf->writeHTML($content, isset($_GET['vuehtml']));
$html2pdf->Output('/home/xxxx/public_html/OP-'.$NOMBRE_ARCHIVO.'.pdf','F');

include('/home/xxxx/public_html/includes/enviador_mail.php');

@mysql_close(CONEXION);
?>
