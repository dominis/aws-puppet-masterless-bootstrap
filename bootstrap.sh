#!/bin/bash
set -ex
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

sudo cp ~/.ssh/config /root/.ssh/
sudo cp ~/.ssh/id_rsa /root/.ssh/

sudo puppet apply --verbose /tmp/bootstrap/site.pp
rm -rf /etc/puppet

instance_id=$(ec2metadata --instance-id)
region=$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | grep region | awk -F\" '{print $4}')
tags=$(ec2-describe-tags --filter "resource-id=${instance_id}" --region ${region})

config_url=$(echo ${tags}|grep Config|cut -f5)
role=$(echo ${tags}|grep Role|cut -f5)

sudo mkdir -p /etc/facter/facts.d
echo "role=${role}" /etc/facer/facts.d/role.txt
echo "config_url=${config_url}" /etc/facer/facts.d/config_url.txt

git clone ${config_url} /tmp/puppet
sudo mv /tmp/puppet /etc/puppet
