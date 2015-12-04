# Resources related to configuring the installed software 
# https://docs.puppetlabs.com/guides/module_guides/bgtm.html

class tada::mountain::config (
  $cupsdconf       = hiera('cupsdconf'),
  $pushfilesh      = hiera('pushfilesh'),
  $astropost       = hiera('astropost'),
  $rsyncpwd        = hiera('rsyncpwd'),
  $mtncache        = hiera('mtncache', '/var/tada/mountain_cache'),
  ) {

  file {  '/etc/tada/dqd.conf':
    ensure     => 'present',
    source => 'puppet:///modules/tada/dqd.transfer.conf',
  }

  file { "$mtncache":
    ensure => 'directory',
    mode   => '0777',
    owner  => 'tada',
  }
  file { '/var/tada/mountain_stash':
    ensure => 'directory',
    mode   => '0777',
    owner  => 'tada',
  }

  firewall { '631 allow cups':
    chain   => 'INPUT',
    state   => ['NEW'],
    dport   => '631',
    proto   => 'tcp',
    action  => 'accept',
  }
  

  ###########################################################################
  ### astro 
  ###
  file {  ['/usr/lib/cups',
           '/usr/lib/cups/lib',
           '/usr/lib/cups/lib/astro',
           '/usr/lib/cups/backend']:
             ensure => directory,
  } 
  file { '/etc/cups/cupsd.conf':
    ensure     => 'present',
    source => "$cupsdconf" ,
    mode   => '0640',
    group  => 'lp',
  } 
  file {  '/usr/lib/cups/lib/astro/pushfile.sh':
    ensure => 'present',
    source => "$pushfilesh",
    mode   => '0555',
    owner  => 'tada',
  } 
  file {  '/usr/lib/cups/backend/astropost':
    ensure => 'present',
    source => $astropost, 
    mode   => '0700',
    owner  => 'root',
  } 

  #################
  file { '/etc/tada/rsync.pwd':
    ensure => 'present',
    source => "$rsyncpwd", 
    mode   => '0400',
    owner  => 'tada',
  } 

  cron { tada_mountain_metrics:
    command => "/opt/tada-cli/scripts/gmetrics-tada.sh MOUNTAIN",
    user    => root,
    minute  => '*/10',
  }

  }
