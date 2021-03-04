#bash to install tomcat

#----------------------
echo "Updating server..."
sudo apt-get -y update 
sudo apt-get -y upgrade
echo "Updating Java..."
sudo apt-get install -y default-jdk 
echo "Installing tomcat8..."
sudo apt-get install -y tomcat8 
sudo apt-get install -y tomcat8-docs tomcat8-examples tomcat8-admin
#bash to admin-user in tomcat
#----------------------------
sed -i 's+</tomcat-users>+  <role rolename="admin-script"/>+gI' /var/lib/tomcat8/conf/tomcat-users.xml
echo '  <role rolename="manager"/>'  >> /var/lib/tomcat8/conf/tomcat-users.xml
echo '  <role rolename="manager-gui"/>'  >> /var/lib/tomcat8/conf/tomcat-users.xml
echo '  <role rolename="manager-script"/>'  >> /var/lib/tomcat8/conf/tomcat-users.xml
echo '  <role rolename="manager-jmx"/>'  >> /var/lib/tomcat8/conf/tomcat-users.xml
echo '  <role rolename="manager-status"/>'  >> /var/lib/tomcat8/conf/tomcat-users.xml
echo '  <user username="tomcat" password="tomcat" roles="admin, manager,admin-script,manager-script,manager-jmx,manager-status,manager-gui,admingui"/>'  >> /var/lib/tomcat8/conf/tomcat-users.xml
echo "</tomcat-users>"  >> /var/lib/tomcat8/conf/tomcat-users.xml
#bash to restart tomcat
#----------------------
echo "Restart tomcat8..."
sudo service tomcat8 restart 
sleep 5
