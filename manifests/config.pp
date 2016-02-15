class tada::config (
  $secrets        = '/etc/rsyncd.scr',
  $rsyncdscr      = 'puppet:///modules/tada-hiera/rsyncd.scr',
  $rsyncdconf     = hiera('rsyncdconf'),
  $rsyncpwd       = hiera('rsyncpwd'),
  $logging_conf   = hiera('tada_logging_conf'),
  $watch_log_conf = hiera('watch_logging_conf'),
  $tada_conf      = hiera('tada_conf'),
  $host_type      = hiera('tada_host_type'),
  $dqd_conf       = hiera('dqd_conf'), #'puppet:///modules/tada/dqd.submit.conf'

  $irodsdata    = hiera('irodsdata'),
  $irodsenv     = hiera('irodsenv'),
  $icmdpath     = '/usr/local/share/applications/irods3.3.1/iRODS/clients/icommands/bin',

  
  $cupsdconf      = hiera('cupsdconf'),
  $pushfilesh     = hiera('pushfilesh'),
  $astropost      = hiera('astropost'),
  $cupsclient   = hiera('cupsclient'),

  $udp_recv_channel   = hiera('udp_recv_channel'),
  $udp_send_channel   = hiera('udp_send_channel'),
  $tcp_accept_channel = hiera('tcp_accept_channel'),

  ) {
  
  user { 'tada' :
    ensure     => 'present',
    comment    => 'For running TADA related services and actions',
    managehome => true, 
    password   => '$1$Pk1b6yel$tPE2h9vxYE248CoGKfhR41',  # tada"Password"
    system     => true,  
  }
  file { [ '/var/run/tada', '/var/log/tada', '/etc/tada', '/var/tada']:
    ensure => 'directory',
    owner  => 'tada',
    #group  => 'root',
    group  => 'tada',
    mode   => '0774',
  }
  file { [ '/var/tada/cache', '/var/tada/anticache', '/var/tada/dropbox', '/var/tada/statusbox']:
    ensure => 'directory',
    owner  => 'tada',
    group  => 'tada',
    mode   => '0744',
  }
  file { '/var/tada/statusbox/tada-ug.pdf':
    ensure => 'present',
    subscribe => [Vcsrepo['/opt/tada'], ],
    owner  => 'tada',
    group  => 'tada',
    mode   => '0400',
    source  => '/opt/tada/docs/tada-ug.pdf',
  }
  file { '/var/tada/personalities':
    ensure  => 'directory',
    owner   => 'tada',
    group   => 'tada',
    mode    => '0744',
    source  => '/opt/tada-cli/personalities',
    recurse => true,
  }
  file { '/home/tada/.tada':
    ensure  => 'directory',
    owner   => 'tada',
    group   => 'tada',
    mode    => '0744',
  }
  file { '/home/tada/.tada/rsync.pwd':
    ensure => 'present',
    owner  => 'tada',
    group  => 'tada',
    mode   => '0400',
    source  => "${rsyncpwd}",
  }
  
  file { ['/var/log/tada/pop.log', '/var/log/tada/pop-detail.log']:
    ensure  => 'present',
    replace => false,
    owner   => 'tada',
    group   => 'tada',
    mode    => '0774',
  }
  file {  '/etc/tada/tada.conf':
    ensure  => 'present',
    replace => false,
    source  => "${tada_conf}",
    group   => 'root',
    mode    => '0774',
  }
  file { '/etc/tada/pop.yaml':
    ensure  => 'present',
    replace => false,
    source  => "${logging_conf}",
    mode    => '0774',
  }
  file { '/etc/tada/watch.yaml':
    ensure  => 'present',
    replace => false,
    source  => "${watch_log_conf}",
    mode    => '0774',
  }
  file { '/var/log/tada/submit.manifest':
    ensure  => 'file',
    replace => false,
    owner   => 'tada',
    mode    => '0766',
  }
  file { '/etc/tada/requirements.txt':
    ensure => 'present',
    source => 'puppet:///modules/tada/requirements.txt',
  }
  file { '/etc/init.d/dqd':
    ensure => 'present',
    source => 'puppet:///modules/tada/dqd',
    owner  => 'tada',
    mode   => '0777',
  }
  file {  '/etc/tada/dqd.conf':
    replace => false,
    ensure  => 'present',
    source  => "${dqd_conf}",
  }
  file {  '/etc/tada/watchpushd.conf':
    ensure  => 'present',
    replace => false,
    source  => 'puppet:///modules/tada/watchpushd.conf',
  }
  file { '/etc/init.d/watchpushd':
    ensure => 'present',
    source => 'puppet:///modules/tada/watchpushd',
    owner  => 'tada',
    mode   => '0777',
  }
  # Not sure if firewall mods needed for dqsvcpop???
  firewall { '000 allow dqsvcpop':
    chain   => 'INPUT',
    state   => ['NEW'],
    dport   => '6379',
    proto   => 'tcp',
    action  => 'accept',
  }
  

  ## Use "ssh -t" instead?
#!  file_line { 'disable_requiretty':
#!    path  => '/etc/sudoers',
#!    line  => '#Defaults    requiretty',
#!    match => 'Defaults    requiretty',
#!  }

#!  class {'ganglia::gmond':
#!    cluster_name       => 'prod_el6',
#!    cluster_owner      => 'National Optical Astronomical Observatory',
#!    cluster_latlong    => 'N32.2332147 W110.9481163',
#!    cluster_url        => 'www.noao.edu',
#!    host_location      => 'NOAO Computer Room',
#!    udp_recv_channel   => $udp_recv_channel,
#!    udp_send_channel   => $udp_send_channel,
#!    tcp_accept_channel => $tcp_accept_channel
  #!  }

  cron { tada_metrics:
    command => "/opt/tada-cli/scripts/gmetrics-tada.sh ${host_type}",
    user    => root,
    minute  => '*/10',
  }


  ##############################################################################
  ### rsync
  file { '/etc/tada/rsync.pwd':
    ensure => 'present',
    source => "$rsyncpwd", 
    mode   => '0400',
    owner  => 'tada',
  } 
  file {  $secrets:
    ensure  => 'present',
    source  => "$rsyncdscr",
    owner   => 'root',
    mode    => '0400',
  }
  file {  '/etc/rsyncd.conf':
    ensure  => 'present',
    replace => false,
    source  => "$rsyncdconf",
    owner   => 'root',
    mode    => '0400',
  }
  service { 'xinetd':
    ensure  => 'running',
    enable  => true,
    require => Package['xinetd'],
    }
  exec { 'rsyncd':
    command   => "/sbin/chkconfig rsync on",
    require   => [Service['xinetd'],],
    subscribe => File['/etc/rsyncd.conf'],
    onlyif    => "/sbin/chkconfig --list --type xinetd rsync | grep off",
  }
  
  firewall { '000 allow rsync':
    chain   => 'INPUT',
    state   => ['NEW'],
    dport   => '873',
    proto   => 'tcp',
    action  => 'accept',
  }

  ###########################################################################
  ### astro: only needed for mountain (until LP replaced by rsync)
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
  firewall { '631 allow cups':
    chain   => 'INPUT',
    state   => ['NEW'],
    dport   => '631',
    proto   => 'tcp',
    action  => 'accept',
  }
  # CUPS (client only)
  file { '/etc/cups/client.conf':
    ensure     => 'present',
    source  => "$cupsclient",
  }

  ###########################################################################
  ### irods: only needed for valley
  ###
  file { '/home/tada/.irods':
    ensure => 'directory',
    owner  => 'tada',
  }
  file { '/home/tada/.irods/.irodsEnv':
    ensure  => 'present',
    replace => false,
    owner   => 'tada',
    source  => "$irodsenv",
    }
  file { '/home/tada/.irods/iinit.in':
    ensure  => 'present',
    replace => false,
    owner   => 'tada',
    source  => "$irodsdata",
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

}

