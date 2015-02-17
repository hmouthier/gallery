#!/bin/bash

fichierLog="/var/log/gallery/cron.log"
msgLog=$(date)
echo "---------------   "$msgLog" : debut surveillance daemon gestion Photo  --------------- " >> $fichierLog

# script de surveillance de daemon

# recuperation du repertoire d entree de gestion des photos
dossier_entree=$(cat $HOME/.gallery.ini | grep dossier_entree | awk -F ' ' '{ print $2}')


# drapeau permettant de savoir si le daemon a un probleme
pbDaemon=0

# on regarde si il y a une operation en cours dans le repertoire d entree
fichierLock=$dossier_entree"/.lock"

# si il y a une operation en cours : on verifie que le daemon operant est en forme
if [ -f $fichierLock ]; then
	echo "une operation est en cours depuis le repertoire "$dossier_entree >> $fichierLog

	# recuperation du pid du daemon
	pidDaemon=$(cat $fichierLock)
	# on verifie qu il tourne encore
	nbProcessus=$(ps -ef | grep -c $pidDaemon)
	# avec la commande du dessus au retrouve aussi le grep
	if [[ $nbProcessus < 2 ]]; then
		pbDaemon=1
		echo "PROBLEME : le processus daemon "$pidDaemon" ne tourne pas"  >> $fichierLog
	else echo "le processus daemon "$pidDaemon" tourne, tout va bien"  >> $fichierLog
	fi

# il n y a pas d operation en cours : on verifie que le daemon tourne
else
	echo "il n y a pas d operation en cours depuis le repertoire "$dossier_entree >> $fichierLog
	# on vérifie que /opt/gallery/gestionPhoto est bien present (en enlevant celui de grep)
	nbProcessus=$(ps -ef | grep -v "grep -c /opt/gallery/gestionPhoto" | grep -c "/opt/gallery/gestionPhoto")
	if [[ $nbProcessus == 1 ]]; then
			echo "Le daemon tourne, tout va bien"  >> $fichierLog
	else 
		pbDaemon=1
		echo "PROBLEME : le daemon ne tourne pas"  >> $fichierLog
	fi
fi

# si pb sur le daemon, on le relance
if [[ $pbDaemon == 1 ]]; then
	echo "redemarrage du daemon..." >> $fichierLog
	/etc/init.d/gestionPhoto.sh start  >> $fichierLog
fi

msgLog=$(date)
echo "---------------   "$msgLog" : fin surveillance daemon gestion Photo   --------------- " >> $fichierLog
