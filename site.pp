$puppetscript = @(PUPPETSCRIPT)
#!/bin/bash
set -x
cd /etc/puppet
git clean -f
git reset --hard HEAD
git checkout .
git pull origin master

librarian-puppet install --path=/etc/puppet/modules

puppet apply --verbose --modulepath=/etc/puppet/modules /etc/puppet/site.pp

PUPPETSCRIPT

node default {
  file { '/usr/local/bin/puppet.sh':
    content     => $puppetscript,
    ensure      => file,
    mode        => "0755",
  }

  cron { 'run puppet':
    command => "sh /usr/local/bin/puppet.sh >> /var/log/puppet-fetch.log 2>&1"
  }

  file { '/etc/puppet':
    ensure  => absent,
  }

  file { [
    '/etc/facter',
    '/etc/facter/facts.d',
    ]:
      ensure  => directory,
  }
}
