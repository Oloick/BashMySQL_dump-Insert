#!/bin/bash
#
#   Faire un script qui va creer une Base de donnée "InnoDB", puis une table "T1"
#	    Fais 100 insert dans la table de 1 à 100
#	    Backup la table
#	    Delete le contenue de la table
#	    Refaire 100 Insert (de 100 à 200 )
#	    Jusqu'a 1000
#@author <loick.ode@ynov.com>
#
# USE bash -x script.sh

#Variables
_DataBaseName="YnovTP_ODE"
_DataBaseTable="T1"
_Backup_path="/root/Documents"
_Date=$(date +"%d-%b-%Y")
_Iteration=0
_IterationMax=9

#Reglage
user=odeloick
password=loick
user_admin=root
password_admin=

echo "CREATE USER '${user}'@'localhost' IDENTIFIED BY '${password}';";
#Création Base & Table
{
  mysql --user=${user_admin} --password=${password_admin} -e "CREATE USER '${user}'@'localhost' IDENTIFIED BY '${password}';"
  mysql --user=${user_admin}  --password=${password_admin} -e "GRANT ALL PRIVILEGES ON *.* TO ${user}@localhost;"
  mysql --user=${user_admin}  --password=${password_admin} -e "FLUSH PRIVILEGES;"
  mysql --user=${user} --password=${password} -e "CREATE DATABASE IF NOT EXISTS ${_DataBaseName};"
  mysql --user=${user} --password=${password} ${_DataBaseName} -e "CREATE TABLE IF NOT EXISTS ${_DataBaseTable} (nombre INT(255));"
} #&> /dev/null;
#Insert recursive
Insert()
{
    if [[ $_Iteration -gt $_IterationMax ]];
    then
      echo " Vous avez terminé l'insertion";
    else
      for i in `seq 1 100`;
        do
          mysql --user=${user} --password=${password} ${_DataBaseName} -e "INSERT INTO ${_DataBaseTable} VALUES ((100*$_Iteration + $i));"
        done

          #Backup
        mysqldump --user=${user} --password=${password} $_DataBaseName > $_Backup_path/$_DataBaseName-$_Iteration-$_Date.sql
          # Delete files older than 1 days
        find $_Backup_path/* -mtime +1 -exec rm {} \;

           #Drop element table
        mysql --user=${user} --password=${password} ${_DataBaseName} -e "DELETE FROM ${_DataBaseTable};"

        let "_Iteration += 1"
        Insert
    fi
} &> /dev/null;
Insert
echo "==== script terminer ====";
