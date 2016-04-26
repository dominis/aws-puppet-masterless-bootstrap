#!/bin/bash
set -x
sudo apt-get update
sudo apt-get dist-upgrade -u -y
sudo apt-get install ec2-api-tools ruby ruby-dev gcc make -y
sudo gem install puppet json librarian-puppet --no-ri --no-rdoc

cat << EOF > ~/.ssh/config
Host *
 UserKnownHostsFile /dev/null
 StrictHostKeyChecking no
 LogLevel=quiet
EOF

sudo mv /home/ubuntu/.ssh/config /root/.ssh/
sudo mv /home/ubuntu/.ssh/id_rsa /root/.ssh/
sudo chown root:root -Rf /root/.ssh/
sudo chmod 600 -Rf /root/.ssh/

sudo puppet apply --verbose /tmp/bootstrap/site.pp

INSTANCE_ID=$(ec2metadata --instance-id)
REGION=$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | grep region | awk -F\" '{print $4}')
ec2-describe-tags --filter "resource-id=${INSTANCE_ID}" --region ${REGION} > /tmp/ec2-tags

CONFIG_URL=$(cat /tmp/ec2-tags |grep Config|cut -f5)
ROLE=$(cat /tmp/ec2-tags|grep Role|cut -f5)

sudo echo "role=$ROLE" > /etc/facter/facts.d/role.txt
sudo echo "config_url=$CONFIG_URL" > /etc/facter/facts.d/config_url.txt

sudo git clone $CONFIG_URL /etc/puppet
