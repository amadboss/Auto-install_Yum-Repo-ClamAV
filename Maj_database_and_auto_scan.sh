#!/bin/bash
# Scan des machines clientes 

#Argument
SCANDIR=$1

#CLAMAV Client
PATHCLAMAV=/usr/bin
PATHBASE=/antivirus/ClamavBase/
CLSCAN=$PATHCLAMAV/clamscan
USERINFECTED=$PATHCLAMAV/client_infected.txt
CLLOG=/var/log/user_clamav.log

#CLAMAV Server
SERVBASE=$PATHBASE/daily.cvd
SERVDATE=`date +"%Y%m%d"`

#Notification Infected
NOTIF_MAIL="<EMAIL>"
NOTIF_ALERTE="[ALERTE] - Serveur $HOSTNAME - Machine Infectée Scan $1"
NOTIF_ENVOYEUR="MACHINE_INFECTEE"
NOTIF_ENVOYEUR1="MACHINE_PAS_SCAN"
NOTIF_BADDATE="Bonjour,\n\n  Le fichier $SERVBASE n'est pas à jour , la date est inférieur à la date du jour \n\n Cordialement \n\n MRF/IPM/SI"
NOTIF_BADDATE1="Bonjour,\n\n  Le fichier $SERVBASE  est absent du repertoire $PATHBASE\n\n Cordialement \n\n MRF/IPM/SI"
NOTIF_ALERTE1="[ALERTE] - Serveur $HOSTNAME - Le Fichier BASE Antivirus sur le Serveur n'est pas à jour"
NOTIF_ALERTE2="[ALERTE] - Serveur $HOSTNAME - Le Fichier BASE Antivirus sur le Serveur n'est pas présent dans $PATHBASE"

# Suppression du fichier client_infected.txt
if [ -f "$USERINFECTED" ]; then
        rm -f $USERINFECTED
fi

# Detection si fichier Base Anti-virus existe et bonne date
if [ -f "$SERVBASE" ]; then

        #Test de la date du fichier daily
        DATE_DAILY=`stat -c %y $SERVBASE |awk '{print $1}'|awk -F"-" '{print $1$2$3}'`
        if [ $DATE_DAILY -eq $SERVDATE ]; then

                #Date correct alors scan
                echo " Débute le scan des fichiers pour les USERS de $1... "
		echo "-------------------------------------------------------------------------------" >> $CLLOG
		echo "-------------------------------------------------------------------------------" >> $CLLOG
		echo "" >> $CLLOG
		echo "NOUVEAU SCAN" >> $CLLOG
		echo `date` >> $CLLOG
                $CLSCAN -r $SCANDIR -i --database=$PATHBASE --log=$CLLOG >> $USERINFECTED
                FILE_INFECTED=`cat $USERINFECTED |grep -i "FOUND" |wc -l`

                        if [ $FILE_INFECTED -gt 0 ]; then
                        echo "MACHINE INFECTE - CONNECTER VOUS SUR LA MACHINE POUR REMOVE LES FICHIERS"

                        ##envoi Mail boite de Groupe
                       mail -s "$NOTIF_ALERTE" -r "$NOTIF_ENVOYEUR" "$NOTIF_MAIL" < $USERINFECTED
                        fi

        else
        # Mauvaise date du fichier dans /mnt/clamav/CLDBASE
        echo -e "$NOTIF_BADDATE" |mail -s "$NOTIF_ALERTE1" -r "$NOTIF_ENVOYEUR1" "$NOTIF_MAIL"
	fi
else
        #pas de fichier sur /mnt/clamav/CLDBASE
        echo -e "$NOTIF_BADDATE1" |mail -s "$NOTIF_ALERTE2" -r "$NOTIF_ENVOYEUR1" "$NOTIF_MAIL"
fi

