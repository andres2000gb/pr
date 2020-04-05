#!/bin/bash
#780205, Ballester Tolón, Fernando, T, 2, A
#779363, Guillén Serrano, Diego, T, 2, A
if [ "$UID" != "0" ]
then
	echo "Este script necesita privilegios de administracion"
	exit 85
fi

if [ "$1" != "-s" ] && [ "$1" != "-a" ];then

echo "Opcion invalida"
exit 85
fi

if [ $# -ne 2 ];then
echo "Numero incorrecto de parametros"
exit 85
fi
fichero="$2"

if [ "$1" == "-a" ];then

while read user; do
nom="${user#*,}"
nombre="${nom##*,}"
contra="${nom%%,*}"
nid="${user%%,*}"

	getent passwd $nid > /dev/null
	if [ $? -eq 0 ];then
		echo "El usuario $nid ya existe"
	else
		if [ -z "$nid" ] || [ -z "$nombre" ] || [ -z "$contra" ]; then
			echo "Campo invalido"
		else

		useradd -c "$nombre" -k /etc/skel -K UID_MIN=1815 -m -U "$nid" 
		usermod -G "$nid" "$nid"		
		echo "$nid:$contra" | chpasswd		
		echo "$nombre ha sido creado"
		fi

	fi
done<${fichero}
else
mkdir -p "/extra/backup"
while read user; do
nid="${user%%,*}"
	getent passwd $nid > /dev/null	
	if [ $? -eq 0 ]; then
		tar fcP /extra/backup/"$nid".tar /home/"$nid" 
		userdel -rf "$nid"
	fi
done<${fichero}
fi

