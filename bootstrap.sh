#!/bin/bash
set -ex
sudo apt-get update
sudo apt-get dist-upgrade -u -y
sudo apt-get install ruby-dev gcc make -y
sudo gem install puppet json librarian-puppet --no-ri --no-rdoc

git clone git@gitlab.com:jackhammer/puppet-config.git /tmp/puppet
sudo mv /tmp/puppet /etc/puppet
cd /etc/puppet
sudo librarian-puppet install --path=./modules
