#!/usr/bin/env bash

if [ "$(. /etc/os-release; echo $NAME)" = "Ubuntu" ]; then
  apt-get update
  apt-get -y install figlet
  SSH_USER=ubuntu
else
  yum install epel-release -y
  yum install figlet -y
  SSH_USER=ec2-user
fi
# Generate system banner
figlet "${welcome_message}" > /etc/motd


##
## Setup SSH Config
##
cat <<"__EOF__" > /home/SSH_USER/.ssh/config
Host *
    StrictHostKeyChecking no
__EOF__
chmod 600 /home/$SSH_USER/.ssh/config
chown $SSH_USER:$SSH_USER /home/SSH_USER/.ssh/config

##
## Setup HTML
##
sudo mkdir -p /opt/iac
sudo chown -R admin.admin /opt/iac
cat <<"__EOF__" > /opt/iac/index.html
<h1>Database Info: </h1>
<p><strong>PostgreSQL Endoint:</strong> ${db_endpoint}</p>
<p><strong>PostgreSQL Instance:</strong> ${db_name}</p>

<footer>
  <p><strong>Posted by:</strong> Jeffry Milan</p>
  <p><strong>Contact information:</strong> <a href="mailto:jeffry.milan@gmail.com">jtmilan@gmail.com</a>.</p>
</footer>
<p><strong>Note:</strong> The environment specified is a naive representation of a web application with a database backend.</p>
__EOF__

${user_data}
