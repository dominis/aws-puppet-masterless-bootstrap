$puppetscript = @(PUPPETSCRIPT)
#!/bin/bash
set -x
/usr/bin/lockfile -l 300 /var/run/puppet-apply.lock || exit 1
cd /usr/src/config/puppet
git clean -f
git reset --hard HEAD
git checkout .
git pull origin master

librarian-puppet install --path=/etc/puppet/modules

puppet apply --verbose --modulepath=/usr/src/config/puppet/modules /usr/src/config/puppet/site.pp

rm -f /var/run/puppet-apply.lock
PUPPETSCRIPT

node default {
  file { '/usr/local/bin/puppet.sh':
    content     => $puppetscript,
    ensure      => file,
    mode        => "0755",
  }

  cron { 'run puppet':
    command         => "sh /usr/local/bin/puppet.sh 2>&1 | logger",
    environment     => "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
    minute          => "*/5",
  }

  file { '/etc/puppet':
    ensure  => absent,
  }

  package { 'procmail':
    ensure => installed,
  }

  file { [
    '/etc/facter',
    '/etc/facter/facts.d',
    ]:
      ensure  => directory,
  }
}
