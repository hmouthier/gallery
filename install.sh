#! /bin/bash

# Installation des dépendances logiciels
apt-get install imagemagick
apt-get install exif

# Création d'un répértoire pour l'application qui va tourner en démon
mkdir /opt/gallery

# Créer Le dossier pour les logs
mkdir /var/log/gallery

# déplacement du fichier cron
cp src/cronGestionPhoto.sh /opt/gallery

# déplacement du fichier de configuration dans le répértoire de l'utilisateur
###############################
echo "Pour quel utilisateur voulez vous installer ce programme ?"
read user
rm /opt/gallery/.gallery.ini
echo "utilisateur "$user >> /opt/gallery/.gallery.ini

test=true
while [ $test == true ]; do
	echo "Dans quel dossier voulez vous importer vos photos ?(chemin depuis le répertoire /home/"$user" vers le dossier)"
	read n
	if [ -d /home/$user/$n ];
		then
			echo "Le dossier existe !"
			test=false
		else
			echo "Le dossier n'existe pas !"
			echo "Voulez vous créer le dossier /home/$user/"$n" ?(O/N)"
			read m
			if [ "$m" == "o" ] || [ "$m" == "O" ];
				then
					mkdir /home/$user/$n
					chgrp -R $user /home/$user/$n
					chown -R $user /home/$user/$n
					test=false
			fi
	fi
done

echo "dossier_entree /home/"$user"/"$n >> /opt/gallery/.gallery.ini


test=true
while [ $test == true ]; do
	echo "Dans quel dossier voulez vous trier vos photos ?(chemin depuis le répertoire /home/"$user" vers le dossier)"
	read k
	if [ -d /home/$user/$k ];
		then
			echo "Le dossier existe !"
			test=false
		else
			echo "Le dossier n'existe pas !"
			echo "Voulez vous créer le dossier /home/$user/"$k" ?(O/N)"
			read m
			if [ "$m" == "o" ] || [ "$m" == "O" ];
				then
					mkdir /home/$user/$k
					chgrp -R $user /home/$user/$k
					chown -R $user /home/$user/$k
					test=false
			fi
	fi
done

echo "dossier_sortie /home/"$user"/"$k >> /opt/gallery/.gallery.ini


###############################



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
/etc/init.d/gestionPhoto.sh start
echo LANCEMENT DU DEMON .. OK

# Ajouter le cron tab
/etc/init.d/cron stop
echo '*/5 *    * * *   root    /bin/bash /opt/gallery/cronGestionPhoto.sh' >> /etc/crontab
/etc/init.d/cron start
