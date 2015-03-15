#!/bin/bash

# Comprobamos si el $USER es root o miembro del grupo ptp sino sale.
if [ !-z $(id |grep ptp) ]; then 
whiptail --title "DevOps Team" --msgbox "el script $0 debe ejecutarse como miembro del grupo ptp" 8 78 
#if [ $(id -un) != "root" ]; then 
#whiptail --title "DevOps Team" --msgbox "el script $0 debe ejecutarse como root" 8 78 
#exit
fi
###

# Verifica si el directorio con los jars existe sino exit
#if [ ! -d "jars_dir" ]; then
#whiptail --title "Advertencia" --msgbox "Debe existir el directorio \"jars_dir\" en el path y contener los jars" 20 30 #--scrolltext
#exit
#fi
###

######################
## MENU DE OPTCIONES #
######################

OPTION=$(whiptail --title "Jars Patching Tool" --menu "Seleccione la opcion" 15 60 4 \
"1" "Aplicar jar en webapp" \
"2" "Aplicar jar en ar.com.primary.jarname" \
"3" "Verificar md5sum" \
"4" "Donar a DevOps team"  3>&1 1>&2 2>&3)

 
exitstatus=$?
if [ $exitstatus = 0 ]; then

#######################
##  SEGUN LA OPCION  ##
#######################

case $OPTION in

1)

# lista de jars
JAR=$(whiptail --title "Jars repo tool" --inputbox "ingrese lista de jars" 10 60  3>&1 1>&2 2>&3)


###
# Seleccionar la webapp a patchear

WEBAPP=$(whiptail --title "Webapp" --checklist \
"Elija la webapp a patchear" 15 60 6 \
"ptp-dashboard" "DASHBOARD" OFF \
"ptp-oms-webservices" "OMS_WEBSERVICES"  OFF \
"ptp-pharos-web" "PHAROS_WEB"  OFF \
"ptp-rima-web" "RIMA_WEB" OFF \
"ptp-webservices" "WEBSERVICES" OFF \
"ptp-rofex-configuration" "CONFIGURATION"  OFF  3>&1 1>&2 2>&3)

sleep 1 
###

###
# Seleccion del server a patchear
#
SERVER=$(whiptail --title "Lista de nodos" --checklist \
"Elija el nodo a patchear" 15 50 6 \
"192.168.12.10" "ws" OFF \
"192.168.12.11" "gw1" OFF \
"192.168.12.12" "gw2" OFF \
"192.168.12.13" "gw3" OFF \
"192.168.12.120" "extmkt" OFF \
"192.168.12.110" "db" OFF \
"192.168.12.100" "bus" OFF \
"192.168.12.101" "me1" OFF \
"192.168.12.102" "me2" OFF \
"192.168.12.115" "multinodo" OFF \
"192.168.12.105" "admin" OFF  3>&1 1>&2 2>&3)
sleep 1



###
# Aplica los parches

for webapp in $WEBAPP
	do
    	for server in $SERVER
    	do
		for jar  in $JAR
			do
#scp -r jars_dir $server:/var/lib/$webapp/webapps/$webapp/WEB-INF/lib
echo  "scp $jar.jar $server:/var/lib/$webapp/webapps/$webapp/WEB-INF/lib/" |sort | sed 's/\"//g'>> webapps_patch.$(date +%d%m%Y).sh 
echo "ssh $server hostname  >> WEAPP_MD5SUM.\$(date +%d%m%Y).LOG; md5sum $server:/var/lib/$webapp/webapps/$webapp/WEB-INF/lib/* >> WEBAPP_MD5SUM.\$(date +%d%m%Y).LOG" |sort | sed 's/\"//g' >> webapps_md5sum.$(date +%d%m%Y).sh
  #     echo "ssh $server hostname >> md5_WEBAPPS.sh; md5sum /var/lib/$webapp/webapps/$webapp/WEB-INF/lib/*  >> MD5_WEBAPPS"
    done
	done
done
##
;;



############################
# REPO JARS PATCHING TOOL  #
#                          #
############################

2)

###
# Seleccion del server a patchear
#
SERVER=$(whiptail --title "Lista de nodos" --checklist \
"Elija el nodo a patchear" 15 50 6 \
"192.168.12.10" "ws" OFF \
"192.168.12.11" "gw1" OFF \
"192.168.12.12" "gw2" OFF \
"192.168.12.13" "gw3" OFF \
"192.168.12.120" "extmkt" OFF \
"192.168.12.110" "db" OFF \
"192.168.12.100" "bus" OFF \
"192.168.12.101" "me1" OFF \
"192.168.12.102" "me2" OFF \
"192.168.12.115" "multinodo" OFF \
"192.168.12.105" "admin" OFF  3>&1 1>&2 2>&3)

sleep 1

JAR=$(whiptail --title "Jars repo tool" --inputbox "ingrese lista de jars" 10 60  3>&1 1>&2 2>&3)

 
exitstatus=$?
if [ $exitstatus = 0 ]; then
# Aplica los parches

for jar  in $JAR
do
    for server in $SERVER
    do
#scp -r jars_dir $server:/usr/share/ptp/repo/ar/com/primary/$repo/   
	echo scp  $jar* $server:/usr/share/ptp/repo/ar/com/primary/$jar/ |  sort | sed 's/\"//g' >> repo.patch.$(date +%d%m%Y).sh
echo "ssh $server hostname  >> REPO_MD5SUM.\$(date +%d%m%Y).LOG; md5sum /usr/share/ptp/repo/ar/com/primary/$jar/* >> REPO_MD5SUM.\$(date +%d%m%Y).LOG" |sort | sed 's/\"//g' >> repo_md5sum.$(date +%d%m%Y).sh
    done
done 
##
fi

	
;;

#3)
#BLABLA
#;; 

*) 
echo "Uso: $0 | sort >> patch.sh # lo que genera es un archivo para ejecutar la aplicacion de los jars o lo que corresponda" 
;;
esac
fi
#fi #| sort |   sed 's/"//g'  >> parche.jars.$(date +%d%m%Y).sh ; echo -e "\n" >>  parche.jars.$(date +%d%m%Y).sh


# Buscar en si cambia la ip del server 
# cat parche.sh | if [ -z $(awk -F'[^0-9]*' '$0=$5') ] ;then echo -e "\n" >> parche.sh
