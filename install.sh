#! /bin/bash

# Installation des dépendances logiciels
apt-get install imagemagick
apt-get install exiftool
apt-get install exif

# déplacement du fichier de configuration dans le répértoire de l'utilisateur
cp .gallery.ini $HOME

# Création d'un répértoire pour l'application qui va tourner en démon
mkdir /opt/gallery

# Déplacement des scripts dans l'arborescence /opt/gallery
cp src/gestionPhoto /opt/gallery
cp -r src/generation_html /opt/gallery

# Déplacement du démon dans le init.d
cp src/gestionPhoto.sh /etc/init.d/.
chmod 0755 /etc/init.d/gestionPhoto.sh

# ajoute le service au démarrage de l'ordinateur
update-rc.d gestionPhoto.sh defaults
echo AJOUT DU SERVICE .. OK

# Lancer le démon
sudo /etc/init.d/gestionPhoto.sh start
echo LANCEMENT DU DEMON .. OK

