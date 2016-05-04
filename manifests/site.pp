$puppetscript = @("PUPPETSCRIPT"/L)
#!/bin/bash
set -e
set -x
cd /etc/puppet
git clean -f
git reset
git checkout .
git pull origin master

librarian-puppet intall --path=/etc/puppet/modules

puppet apply --verbose --modulepath=/etc/puppet/modules /etc/puppet/manifests/site.pp

| PUPPETSCRIPT

node default {
    file { '/usr/local/bin/puppet.sh':
        contents    => $puppetscript,
        ensure      => file,
        mode        => "0755",
    }

    cron { 'run puppet':
        command => "/usr/local/bin/puppet.sh >> /var/log/puppet-fetch.log 2>&1",
        user => root,
    }
}
