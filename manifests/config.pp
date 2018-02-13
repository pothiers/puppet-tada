class tada::config (
  $secrets        = '/etc/rsyncd.scr',
  $rsyncdscr      = hiera('rsyncdscr'),
  $rsyncdconf     = hiera('rsyncdconf'),
  $rsyncpwd       = hiera('rsyncpwd'),
  $logging_conf   = hiera('tada_logging_conf'),
  $dqcli_log_conf = hiera('dqcli_logging_conf'),
  $watch_log_conf = hiera('watch_logging_conf'),
  $tada_conf      = hiera('tada_conf'),
  $smoke_conf     = hiera('smoke_conf'),
  $host_type      = hiera('tada_host_type'),
  #$dqd_conf       = hiera('dqd_conf'),
  $dq_loglevel    = hiera('dq_loglevel'),
  $qname          = hiera('qname'),

  $irodsdata    = hiera('irodsdata'),
  $irodsenv     = hiera('irodsenv'),
  $icmdpath     = '/usr/local/share/applications/irods3.3.1/iRODS/clients/icommands/bin',
  $udp_recv_channel   = hiera('udp_recv_channel'),
  $udp_send_channel   = hiera('udp_send_channel'),
  $tcp_accept_channel = hiera('tcp_accept_channel'),
  $inotify_instances  = hiera('inotify_instances', '512'),
  $inotify_watches    = hiera('inotify_watches', '1048576'),

  # Use these to install a yaml file that TADA can use to get underlying values
  $dq_host             = hiera('dq_host'),
  $dq_port             = hiera('dq_port'),
  $arch_host           = hiera('arch_host'),
  $arch_port           = hiera('arch_port'),
  $arch_timeout        = hiera('arch_timeout'),
  $arch_irods_host     = hiera('arch_irods_host'),
  $arch_irods_port     = hiera('arch_irods_port'),
  $arch_irods_resource = hiera('arch_irods_resource'),
  $archive_irods331    = hiera('archive_irods331'),
  $valley_host         = hiera('valley_host'),
  $mars_host           = hiera('mars_host'),
  $mars_port           = hiera('mars_port'),
  $tadaversion         = hiera('tadaversion'),
  $dataqversion        = hiera('dataqversion'),
  $marsversion         = hiera('marsversion'),
  ) {
  file { [ '/var/run/tada', '/var/log/tada', '/etc/tada', '/var/tada']:
    ensure => 'directory',
    owner  => 'tada',
    #group  => 'root',
    group  => 'tada',
    mode   => '0774',
  }
  file { '/var/tada/data':
    ensure => 'directory',
    owner  => 'tada',
    group  => 'tada',
    mode   => '0774',
  }
  file { ['/var/tada/data/cache',
          '/var/tada/data/anticache',
          '/var/tada/data/dropbox',
          '/var/tada/data/nowatch',
          '/var/tada/data/statusbox']:
    ensure => 'directory',
    owner  => 'tada',
    group  => 'tada',
    mode   => '0744',
  }
  file { '/var/tada/cache' :
    ensure  => 'link',
    replace => false,
    target  => '/var/tada/data/cache',
  }
  file { '/var/tada/anticache' :
    ensure  => 'link',
    replace => false,
    target  => '/var/tada/data/anticache',
  }
  file { '/var/tada/dropbox' :
    ensure  => 'link',
    replace => false,
    target  => '/var/tada/data/dropbox',
    owner  => 'tada',
    group  => 'tada',
    mode   => '0744',
  }
  file { '/var/tada/nowatch' :
    ensure  => 'link',
    replace => false,
    target  => '/var/tada/data/nowatch',
  }
  file { '/var/tada/statusbox' :
    ensure  => 'link',
    replace => false,
    target  => '/var/tada/data/statusbox',
  }
  file { '/var/tada/statusbox/tada-ug.pdf':
    ensure    => 'present',
    replace => true,
    subscribe => [Vcsrepo['/opt/tada'], ],
    owner     => 'tada',
    group     => 'tada',
    mode      => '0400',
    source    => '/opt/tada/docs/tada-ug.pdf',
  }
  file { '/var/tada/personalities':
    ensure  => 'link',
    replace => true,
    #owner   => 'tada',
    #group   => 'tada',
    #mode    => '0744',
    target  => '/opt/tada-cli/personalities',
  }
  file { '/usr/local':
    ensure => 'directory',
  }
  file { '/usr/local/bin':
    ensure => 'directory',
  }
  file { '/home/tada/.tada':
    ensure  => 'directory',
    owner   => 'tada',
    group   => 'tada',
    mode    => '0744',
  }
  file { '/home/tada/.tada/rsync.pwd':
    ensure  => 'present',
    replace => false,
    owner   => 'tada',
    group   => 'tada',
    mode    => '0400',
    source  => "${rsyncpwd}",
  }
  file { '/home/tester/.tada':
    ensure  => 'directory',
    owner   => 'tester',
    group   => 'tada',
    mode    => '0744',
  }
  file { '/home/tester/.tada/rsync.pwd':
    ensure  => 'present',
    replace => false,
    owner   => 'tester',
    mode    => '0400',
    source  => "${rsyncpwd}",
  }
  file { '/home/tester/activate':
    ensure  => 'present',
    replace => false,
    owner   => 'tester',
    mode    => '0555',
    content => "source /opt/tada/venv/bin/activate",
  }
  file { ['/var/log/tada/pop.log', '/var/log/tada/pop-detail.log']:
    ensure  => 'present',
    replace => false,
    owner   => 'tada',
    group   => 'tada',
    mode    => '0774',
  }
  file { ['/var/log/tada/dqcli.log', '/var/log/tada/dqcli-detail.log']:
    ensure  => 'present',
    replace => false,
    owner   => 'tada',
    group   => 'tada',
    mode    => '0777',
  }
  file {  '/etc/tada/smoke-config.sh':
    ensure  => 'present',
    replace => false,
    source  => "${smoke_conf}",
    group   => 'root',
    mode    => '0774',
  }
  file {  '/etc/tada/tada.conf':
    ensure  => 'present',
    replace => false,
    source  => "${tada_conf}",
    group   => 'root',
    mode    => '0774',
  }
  file {  '/etc/tada/hiera.yaml': # I should name this differently!!!
    ensure  => 'present',
    replace => true,
    content => "---
dq_host: ${dq_host}
dq_port: ${dq_port}
dq_loglevel: ${dq_loglevel}
arch_host: ${arch_host}
arch_port: ${arch_port}
arch_timeout: ${arch_timeout}
arch_irods_host: ${arch_irods_host}
arch_irods_port: ${arch_irods_port}
arch_irods_resource: ${arch_irods_resource}
archive_irods331: ${archive_irods331}
valley_host: ${valley_host}
mars_host: ${mars_host}
mars_port: ${mars_port}
tadaversion: ${tadaversion}
dataqversion: ${dataqversion}
marsversion: ${marsversion}
",
    group   => 'root',
    mode    => '0774',
  }

  file { '/etc/tada/pop.yaml':
    ensure  => 'present',
    replace => false,
    source  => "${logging_conf}",
    mode    => '0774',
  }
  file { '/etc/tada/dataq_cli_logconf.yaml':
    ensure  => 'present',
    replace => false,
    source  => "${dqcli_log_conf}",
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
    replace => false,
    source => 'puppet:///modules/tada/requirements.txt',
  }
  file { '/etc/tada/audit-schema.sql':
    ensure => 'present',
    replace => false,
    source => 'puppet:///modules/tada/audit-schema.sql',
  }
  file { '/etc/init.d/dqd':
    ensure => 'present',
    replace => true,
    source => 'puppet:///modules/tada/dqd',
    owner  => 'tada',
    mode   => '0777',
  }
  file {  '/etc/tada/dqd.conf':
    ensure  => 'present',
    replace => false,
    content => "
qname=${qname}
dqlevel=${dq_loglevel}
",
  }
  file {  '/etc/tada/watchpushd.conf':
    ensure  => 'present',
    replace => false,
    source  => 'puppet:///modules/tada/watchpushd.conf',
  }
  file { '/etc/tada/EXAMPLE_prefix_table.csv':
    ensure => 'present',
    replace => false,
    source => 'puppet:///modules/tada/prefix_table.csv',
    owner  => 'tada',
    mode   => '0777',
  }
  file { '/etc/init.d/watchpushd':
    ensure  => 'present',
    replace => true,
    source  => 'puppet:///modules/tada/watchpushd',
    owner   => 'tada',
    mode    => '0777',
  }
  # Not sure if firewall mods needed for dqsvcpop???
  firewall { '000 allow dqsvcpop':
    chain   => 'INPUT',
    state   => ['NEW'],
    dport   => '6379',
    proto   => 'tcp',
    action  => 'accept',
  }

  file_line { 'config_inotify_instances':
    ensure => present,
    path   => '/etc/sysctl.conf',
    match  => '^fs.inotify.max_user_instances\ \=',
    line   => "fs.inotify.max_user_instances = $inotify_instances",
  }
  file_line { 'config_inotify_watches':
    ensure => present,
    path   => '/etc/sysctl.conf',
    match  => '^fs.inotify.max_user_watches\ \=',
    line   => "fs.inotify.max_user_watches = $inotify_watches",
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

  cron { 'tada_metrics':
    command => "/opt/tada-cli/scripts/gmetrics-tada.sh ${host_type}",
    user    => root,
    minute  => '*/10',
  }


  ##############################################################################
  ### rsync
  file { '/etc/tada/rsync.pwd':
    ensure => 'present',
    replace => false,
    source => "${rsyncpwd}",
    mode   => '0400',
    owner  => 'tada',
  }
  file {  $secrets:
    ensure  => 'present',
    replace => false,
    source  => "${rsyncdscr}",
    owner   => 'root',
    mode    => '0400',
  }
  file {  '/etc/rsyncd.conf':
    ensure  => 'present',
    replace => true,
    source  => "${rsyncdconf}",
    owner   => 'root',
    mode    => '0400',
  }
  service { 'xinetd':
    ensure  => 'running',
    enable  => true,
    require => Package['xinetd'],
    }
  exec { 'rsyncd':
    command   => '/sbin/chkconfig rsync on',
    require   => [Service['xinetd'],],
    subscribe => File['/etc/rsyncd.conf'],
    onlyif    => '/sbin/chkconfig --list --type xinetd rsync | grep off',
  }
  firewall { '000 allow rsync':
    chain   => 'INPUT',
    state   => ['NEW'],
    dport   => '873',
    proto   => 'tcp',
    action  => 'accept',
  }

  ###########################################################################
  ### irods: only needed for valley but ok for mountain too;
  ### added for "tester" user
  ###
  file { '/home/tada/.irods':
    ensure => 'directory',
    owner  => 'tada',
  }
  file { '/home/tada/.irods/.irodsEnv':
    ensure  => 'present',
    replace => false,
    owner   => 'tada',
    source  => "${irodsenv}",
  }
  file { '/home/tada/.irods/iinit.in':
    ensure  => 'present',
    replace => false,
    owner   => 'tada',
    source  => "${irodsdata}",
  }
  file { '/etc/tada/iinit.in':
    ensure  => 'present',
    replace => false,
    source  => "${irodsdata}",
  }
  exec { 'iinit':
    environment => ['irodsEnvFile=/home/tada/.irods/.irodsEnv',
                    'HOME=/home/tada' ],
    command     => "${icmdpath}/iinit `cat /home/tada/.irods/iinit.in`",
    user        => 'tada',
    creates     => '/home/tada/.irods/.irodsA',
    subscribe   => [Exec['unpack irods'],
                    File[ '/home/tada/.irods/.irodsEnv',
                          '/home/tada/.irods/iinit.in']],
  }
  ### TESTER user
  file { '/home/tester/.irods':
    ensure => 'directory',
    owner  => 'tester',
  }
  file { '/home/tester/.irods/.irodsEnv':
    ensure  => 'present',
    replace => false,
    owner   => 'tester',
    source  => "${irodsenv}",
  }
  file { '/home/tester/.irods/iinit.in':
    ensure  => 'present',
    replace => false,
    owner   => 'tester',
    source  => "${irodsdata}",
  }
  exec { 'iinit tester':
    environment => ['irodsEnvFile=/home/tester/.irods/.irodsEnv',
                    'HOME=/home/tester' ],
    command     => "${icmdpath}/iinit `cat /home/tester/.irods/iinit.in`",
    user        => 'tester',
    creates     => '/home/tester/.irods/.irodsA',
    subscribe   => [Exec['unpack irods'],
                    File[ '/home/tester/.irods/.irodsEnv',
                          '/home/tester/.irods/iinit.in']],
  }
  
  file { '/etc/logrotate.d/tada':
    ensure  => 'present',
    replace => true,
    source  => 'puppet:///modules/tada/tada.logrotate',
  }

  file { '/home/tester/.ssh/':
    ensure => 'directory',
    owner  => 'tester',
    mode   => '0700',
  } 
  file { '/home/tester/.ssh/authorized_keys':
    owner  => 'tester',
    mode   => '0600',
  }
  }

