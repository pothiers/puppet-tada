# Resources related to configuring the installed software 
# https://docs.puppetlabs.com/guides/module_guides/bgtm.html

class tada::valley::config (
  $icmdpath     = '/usr/local/share/applications/irods3.3.1/iRODS/clients/icommands/bin',
  $logging_conf = hiera('tada_logging_conf'),
  $irodsdata    = hiera('irodsdata'),
  $irodsenv     = hiera('irodsenv'),
  $cupsclient   = hiera('cupsclient'),
  ) {
  
  file {  '/etc/tada/dqd.conf':
    ensure     => 'present',
    source => 'puppet:///modules/tada/dqd.submit.conf',
  }

  #!file { [ '/var/tada/mountain-mirror', '/var/tada/noarchive']:
  file { [ '/var/tada/cache', '/var/tada/anticache']:
    ensure => 'directory',
    owner  => 'tada',
    mode   => '0744',
  }

  firewall { '000 allow dqsvcpop':
    chain   => 'INPUT',
    state   => ['NEW'],
    dport   => '6379',
    proto   => 'tcp',
    action  => 'accept',
  }
  

  ####
  ## Irods
  file { '/home/tada/.irods':
    ensure => 'directory',
    owner  => 'tada',
  }
  file { '/home/tada/.irods/.irodsEnv':
    ensure     => 'present',
    owner  => 'tada',
    source => "$irodsenv",
    }
  file { '/home/tada/.irods/iinit.in':
    ensure     => 'present',
    owner  => 'tada',
    source => "$irodsdata",
  }
  exec { 'iinit':
    environment => ['irodsEnvFile=/home/tada/.irods/.irodsEnv',
                   'HOME=/home/tada' ],
    command     => "${icmdpath}/iinit `cat /home/tada/.irods/iinit.in`",
    user        => 'tada',
    creates     => '/home/tada/.irods/.irodsA',
    require     => [Exec['unpack irods'],
                    File[ '/home/tada/.irods/.irodsEnv',
                          '/home/tada/.irods/iinit.in']],
  }

  ###
  # CUPS (client only)
  file { '/etc/cups/client.conf':
    ensure     => 'present',
    source  => "$cupsclient",
  }

  cron { tada_valley_metrics:
    command => "/opt/tada-cli/scripts/gmetrics-tada.sh VALLEY",
    user    => root,
    minute  => '*/10',
  }

  }
