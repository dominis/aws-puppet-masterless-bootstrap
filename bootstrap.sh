#!/bin/bash
set -ex
sudo apt-get update
sudo apt-get dist-upgrade -u -y
sudo apt-get install ruby-dev gcc make -y
sudo gem install puppet json librarian-puppet --no-ri --no-rdoc

cat << EOF > ~/.ssh/config
Host *
 UserKnownHostsFile /dev/null
 StrictHostKeyChecking no
 LogLevel=quiet
EOF

sudo puppet apply --verbose /tmp/bootstrap/site.pp

rm -rf /etc/puppet

git clone git@gitlab.com:jackhammer/puppet-config.git /tmp/puppet
sudo mv /tmp/puppet /etc/puppet
