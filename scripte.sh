#POUR EXECUTER LE SCRIPTE FAIRE LA COMMANDE "SOURCE <nom du scripte sans les accolde>"
#Mohammad Amad
#REP_YUM_REPO="/etc/yum.repos.d"
#RATP_REPO_FILE="RATP.repo"
#REP_CentOS_TMP="CentOS_TMP"
#REP_REPO="/RATP-repo/"

/usr/bin/mkdir /home/clamav/
/usr/bin/mkdir -p /antivirus/ClamavBase/
mv <Scripte_de_scan_client> /home/clamav/
mv scripte_client.sh /home/clamav/
/usr/bin/mount <IP DU NAS>:/vol/Vsavbase/Qsavbase.u/clamav /antivirus/ClamavBase/
echo "<IP DU NAS>:/vol/Vsavbase/Qsavbase.u/clamav /antivirus/ClamavBase/    nfs     rw      0 0" >> /etc/fstab

if [ -d /etc/yum.repos.d/old ];then
	echo "old existe"
	mv /etc/yum.repos.d/*.repo /etc/yum.repos.d/old/
else
	/usr/bin/mkdir /etc/yum.repos.d/old/
	mv /etc/yum.repos.d/*.repo /etc/yum.repos.d/old/
	rm -r /etc/yum.repos.d/*.repo
fi

if [ -f /etc/yum.repos.d/RATP.repo ];then
    echo "ratp.repo existe"
    cd /etc/yum.repos.d/
	cp -r RATP.repo /etc/yum.repos.d/old
	rm -r /etc/yum.repos.d/RATP.repo
else
	echo "ratp.repo existe PAS"
	cd /etc/yum.repos.d/
    cat <<EOF >RATP.repo
[base]
name=CentOS-\$releasever - Base RATP
baseurl=<IP DU SERVEUR DE REPOSITORY>
 
[extras]
name=CentOS-\$releasever - centosplus RATP
baseurl=<IP DU SERVEUR DE REPOSITORY>

[updates]
name=CentOS-\$releasever - extras RATP 
baseurl=<IP DU SERVEUR DE REPOSITORY>
 
[centosplus]
name=CentOS-\$releasever\ - updates RATP
baseurl=<IP DU SERVEUR DE REPOSITORY>
EOF
fi
#Ici on controle CNTLM et les variable d'environnement proxy
find /usr/sbin/ -name cntlm | wc -l
if [ "$(find /usr/sbin/ -name cntlm | wc -l)" = 1 ];then
echo "cntlm existe desintallation en cours"
yum remove cntlm -y
        if [ "$http_proxy" != "" ] || [ "$https_proxy" != "" ] || [ "$ftp_proxy" != "" ];then
        export http_proxy=
        export https_proxy=
        export ftp_proxy=
        echo "Variable d'environnement proxy reset"
        else
        echo "Pas de Variable d'environnement proxy"
        fi
fi



/usr/bin/yum clean all
/usr/bin/yum autoremove
/usr/bin/yum update -y

#On verifie si tout les repoliste on bien des paquet < 0 sinon il y a un probleme

yum repolist | awk '{print $6,$7}' | grep -v hostfile | grep -v "dépôt" | sort -u | sed '1d' >> /tmp/Verifrepo.txt

while read line;
do
   if [ "$line" = "0" ];then
   echo "Problem Il y a un probleme avec la repoliste"
   else
   echo "Repository OK"
   fi
done </tmp/Verifrepo.txt
#echo $line
/usr/bin/rm -f /tmp/Verifrepo.txt
/usr/bin/yum install clamav -y

echo "31 05 * * * /bin/bash /home/clamav/<Scripte_de_scan_client> / 2>&1" >> /var/spool/cron/root
echo "00 06,12,19 * * * /bin/bash /home/clamav/<Scripte_de_scan_client>  /home 2>&1" >> /var/spool/cron/root


	
