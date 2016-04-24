$puppetscript = @(PUPPETSCRIPT)
#!/bin/bash
set -e
set -x
cd /etc/puppet
git clean -f
git reset
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
    command => "/usr/local/bin/puppet.sh"
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
