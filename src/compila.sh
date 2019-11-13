#! /bin/sh

#===============================================================================
# Script para compilar y ejecutar relatos interactivos programados en Inform 6.
# Herramientas utilizadas:
#	<>	bresc:			Blorb resource compiler (sólo en Glulx)
#	<>	gargoyle-free:	Intérprete multi-plataforma
#	<>	inform:			Compilador Inform 6
#-------------------------------------------------------------------------------

bresc_location=~/data/bin
zcode_interpreter=gargoyle-free
glulx_interpreter=gargoyle-free

web_location=../../nginx/html/ods/resources

inform_path=,/usr/share/inform6/library/,/usr/share/inform6/extensions/,/usr/share/inform6/extensions/gwindows/,/usr/share/inform6/extensions/vorple/

#-------------------------------------------------------------------------------

preprocesa_textos() {
	for i in *.xinf; do
	    [ -f "$i" ] || break
		perl ./preprocesaTexto.pl "$i" "${i%.xinf}.inf"
	done
}

limpia_ficheros_temporales() {
	for i in *.xinf; do
	    [ -f "$i" ] || break
		rm "${i%.xinf}.inf"
	done
	if [ -e "$gameFile.ulx" ]; then
		rm $gameFile.ulx
	fi
}

#-------------------------------------------------------------------------------

if [ "$1" != "" ]; then gameFile=$1;
else
	echo -n "Introduce el nombre del archivo (sin la extensión): ";
	read gameFile;
	echo " ";
fi
if [ ! -e "$gameFile.inf" ]; then
	echo "El archivo '$gameFile.inf' no existe.";
	exit 1;
fi

# Elimina los ficheros antiguos:
if [ -e "../$gameFile.gblorb" ]; then
	rm ../$gameFile.gblorb
fi
if [ -e "$web_location/$gameFile.gblorb" ]; then
	rm $web_location/$gameFile.gblorb
fi

echo "============================================="
echo "COMPILANDO PARA GLULX…"
echo "---------------------------------------------"
preprocesa_textos
inform +include_path=$inform_path -G $gameFile.inf $gameFile.ulx
$bresc_location/bres $gameFile.res
inform +include_path=$inform_path -G $gameFile.inf
$bresc_location/bresc $gameFile.res
cp $gameFile.gblorb $web_location/$gameFile.gblorb
mv $gameFile.gblorb ../$gameFile.gblorb
limpia_ficheros_temporales

echo " "
echo -n "Pulsa cualquier tecla para ejecutar la aplicación ('q' para salir): "
read key

if [ "$key" = "q" ]; then exit 0;
fi
if [ "$key" = "Q" ]; then exit 0;
fi
cd ..
$glulx_interpreter $gameFile.gblorb

exit 0;
