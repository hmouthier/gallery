#!/bin/bash
echo IL FAUDRA QUE LE SCRIPT D INSTALLATION INSTALLE EXIF
echo param 1 = chemin absolu du repertoire contenant les albums!!
# ex : 15/02 ../scripts/genhtml.sh /home/cwamgis/Bureau/exif/html/photos/

#recuperation du repertoire de depart
repDepart=$(pwd)

#repertoire courant du script
pathScript=`echo "$0" | sed -e "s/[^\/]*$//"`
echo $pathScript

#fichiers de sortie html
suffixeFichierResTmp="visuAlbumsTmp.html"
fichierSortieTmp=$1"/"$suffixeFichierResTmp

suffixeFichierRes="visuAlbums.html"
fichierSortie=$1"/"$suffixeFichierRes

# fichier temporaire de description exif
suffixeFichierTmp="tmpExif.html"
fichierExif=$1"/"$suffixeFichierTmp


#entete
entete="entete.html"
cat "$pathScript$entete" > $fichierSortieTmp

#pied
pied="footer.html"

cmpAlbums=1
cd $1

# on efface le rep js css
#rm -R jscssimg

# Parcours de chaque repertoire chantier
for album in *
	do
		# test repertoire
		if [ -d $album ] && [ $album != "jscssimg" ]
			then
				
				cd $album
				echo "<article><h2>"$album"</h2>"  >> $fichierSortieTmp
				echo "<div class=\"container\" id=\"container"$cmpAlbums"\"><div class=\"photoDiv\"><ul>"  >> $fichierSortieTmp
				cmpPhoto=0
				echo "" > $fichierExif
				for photo in *
					do
					if [ $photo != "mini" ]
						then
							# image
							echo "<li><a href=\"$album/$photo\"><img src=\""$album"/mini/"$photo"\" alt=\"\" /></a></li>"  >> $fichierSortieTmp
							# metadonnees exif
							echo "<div id=\"description_slide_"$cmpAlbums"_photo_"$cmpPhoto"\" class=\"metaDiv\"><div>Date : " >> $fichierExif
							exif $photo | grep -m 1 "Date et" | awk -F '|' '{ print $2}' >> $fichierExif
							echo "</div><div>Dimensions : " >> $fichierExif
							exif $photo | grep -m 1 "Pixel X Dimension" | awk -F '|' '{ print $2}' >> $fichierExif
							echo " x " >> $fichierExif
							exif $photo | grep -m 1 "Pixel Y Dimension" | awk -F '|' '{ print $2}' >> $fichierExif
							echo "</div></div>"  >> $fichierExif
							
							((cmpPhoto=$cmpPhoto+1))
					fi
				done
				# bouton de parcours des photos
				echo "</ul><span class=\"button prevButton\" id=\"button1_"$cmpAlbums"\"></span><span class=\"button nextButton\" id=\"button2_"$cmpAlbums"\"></span><input type=\"hidden\" value=\"0\" id=\"current_"$cmpAlbums"\" /></div>"   >> $fichierSortieTmp
				
				# recopie des metadonnees sauvegardees
				cat $fichierExif >> $fichierSortieTmp
				
				echo "</div></article>" >> $fichierSortieTmp
				
				((cmpAlbums=$cmpAlbums+1))
				cd ..
		fi
done

# on revient dans le repertoire de depart
cd $repDepart

# pied de page
echo "<footer>Galerie mis à jour le " >> $fichierSortie
date >> $fichierSortieTmp
echo "</footer>" >> $fichierSortieTmp
cat "$pathScript$pied" >> $fichierSortieTmp
# suppression fichier temporaire
rm $fichierExif
# copie fichiers assets
cp -Rvf $pathScript"jscssimg" $1

# on remplace le fichier html
cp -f $fichierSortieTmp $fichierSortie
rm -f $fichierSortieTmp
