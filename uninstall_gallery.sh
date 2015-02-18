#! /bin/bash

# Arrêter le cron
sed '//d' /etc/crontab

# Arrêter le démon
/etc/init.gestionPhoto.sh stop

# Ne plus jamais lancer le démon au demarrage 
update-rc.d -f gestionPhoto.sh remove

# Supprimer les fichiers et les dossiers relatifs à l'application
rm -r /opt/gallery
rm /etc/init.d/gestionPhoto.sh
rm -r /var/log/gallery
