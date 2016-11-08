
class tada::install (
  $fpacktgz    = hiera('fpacktgz', 'puppet:///modules/tada/fpack-bin-centos-6.6.tgz'),
  $irodstgz    = hiera('irodstgz', 'puppet:///tada/irods-3.3.1.tgz'),
  $tadaversion = hiera('tadaversion', 'master'),
  $dataqversion = hiera('dataqversion', 'master'),
  ) {
  notice("Loading tada::install; tadaversion=${tadaversion}, dataqversion=${dataqversion}")
  
  $stamp=strftime("%Y-%m-%d %H:%M:%S")
  
  #!exec { 'upgrade-pip':
  #!  command  => '/usr/bin/pip3.4 install --upgrade pip'
  #!}
  

  # these are also given by: puppet-sdm
  #! include epel
  #!package { ['git', ]: }
ensure_resource('package', ['git', 'libyaml'], {'ensure' => 'present'})
  
  include augeas

  # for creating python package rpms
  #! package { ['rpm-build',  'rubygems', 'ruby-devel'] : }
  # exec: fpm --python-bin python3 -s python -t rpm setup.py

  package { ['xinetd', 'postgresql-devel'] : }
  yumrepo { 'ius':
    descr      => 'ius - stable',
    baseurl    => 'http://dl.iuscommunity.org/pub/ius/stable/CentOS/6/x86_64/',
    enabled    => 1,
    gpgcheck   => 0,
    priority   => 1,
    mirrorlist => absent,
  }
  -> Package<| provider == 'yum' |>

  #!yumrepo { 'python-tada':
  #!  descr    => 'python-tada',
  #!  baseurl  => "http://mirrors.sdm.noao.edu/tada",
  #!  enabled  => 1,
  #!  gpgcheck => 0,
  #!  priority => 1,
  #!  mirrorlist => absent,
  #!}
  #!yumrepo { 'python-dataq':
  #!  descr    => 'python-dataq',
  #!  baseurl  => "http://mirrors.sdm.noao.edu/dataq",
  #!  enabled  => 1,
  #!  gpgcheck => 0,
  #!  priority => 1,
  #!  mirrorlist => absent,
  #!}
  #!-> Package<| provider == 'yum' |>
  #!-> package{ ['python-dataq', 'python-tada'] :
  #!  ensure => 'installed';  #  or <version number>, or 'latest'
  #!}

  # These install tada,dataq from source in /opt/tada,data-queue
  exec { 'install tada':
    cwd     => '/opt/tada',
    command => '/opt/tada/venv/bin/python3 setup.py install',
    creates => '/opt/tada/venv/bin/direct_submit',
    user    => 'tada',
    require  => [
      File['/opt/tada/venv'],
      Python::Requirements['/opt/tada/requirements.txt'],
    ],
  } 
  exec { 'install dataq':
    cwd     => '/opt/data-queue',
    command => '/opt/tada/venv/bin/python3 setup.py install',
    creates => '/opt/tada/venv/bin/dqsvcpop',
    user    => 'tada',
    notify  => [Service['watchpushd'], Service['dqd'], ],
    require  => [
      File['/opt/tada/venv'],
      Python::Requirements['/opt/tada/requirements.txt'],
    ],
  }

  
 
#!  yumrepo { 'dmo':
#!    descr    => 'dmo',
#!    baseurl  => "http://mirrors.sdm.noao.edu/dmo",
#!    enabled  => 1,
#!    gpgcheck => 0,
#!    priority => 1,
#!    mirrorlist => absent,
#!  }
#!  -> Package<| provider == 'yum' |>
#! ensure_resource('package', ['mcollective-facter-facts', ], {'ensure' => 'present'})  
  
  #!package { ['python34u-pip']: } ->
  #!class { 'python':
  #!  version    => '34u',
  #!  pip        => false,
  #!  dev        => true,
  #!} ->
  #!file { '/usr/bin/pip':
  #!  ensure => 'link',
  #!  target => '/usr/bin/pip3.4',
  #!} ->
  #!file { '/usr/local/bin/python3':
  #!  ensure => 'link',
  #!  target => '/usr/bin/python3',
  #!} ->
  #!python::requirements { '/etc/tada/requirements.txt':
  #!  owner  => 'root',
  #!} ->
  class { 'python' :
    version    => 'python35u',
    pip        => 'present',
    dev        => 'present',
    virtualenv => 'absent', # 'present',
    gunicorn   => 'absent',
    } ->
  file { '/usr/bin/python3':
    ensure => 'link',
    target => '/usr/bin/python3.5',
    } ->
  python::pyvenv  { '/opt/tada/venv':
    version  => '3.5',
    owner    => 'tada',
    require  => [ User['tada'], ],
  } ->
  python::requirements  { '/opt/tada/requirements.txt':
    virtualenv => '/opt/tada/venv',
    owner    => 'tada',
    require  => [ User['tada'], ],
  }

  
  #! Class['python']
  #! -> Package['python34u-pip']
  #! -> File['/usr/bin/pip']
  #! -> File['/usr/local/bin/python3']
  #! -> Python::Requirements['/etc/tada/requirements.txt']
  #! -> Package['dataq', 'tada']
  #! -> Service['dqd']
  
  class { 'redis':
    version           => '2.8.19',
    redis_max_memory  => '1gb',
  }
  
  vcsrepo { '/opt/tada-cli' :
    ensure   => latest,
    provider => git,
    source   => 'https://github.com/NOAO/tada-cli.git',
    revision => 'master',
  }
  user { 'tada' :
    ensure     => 'present',
    comment    => 'For running TADA related services and actions',
    managehome => true,
    password   => '$1$Pk1b6yel$tPE2h9vxYE248CoGKfhR41',  # tada"Password"
    system     => true,
  } 
  user { 'tester' :
    ensure     => 'present',
    comment    => 'For running TADA related tests',
    managehome => true,
    password   => '$1$Pk1b6yel$tPE2h9vxYE248CoGKfhR41',  # tada"Password"
    groups     => ['tada'],
    system     => false,
  } 
  vcsrepo { '/opt/tada' :
    #!ensure   => latest,
    ensure   => present,
    provider => git,
    source   => 'https://github.com/pothiers/tada.git',
    #!revision => 'master',
    revision => "${tadaversion}",
    owner    => 'tada',
    group    => 'tada',
    require  => User['tada'],
    notify   => Exec['install tada'],
  } 
  vcsrepo { '/opt/data-queue' :
    ensure   => present,
    provider => git,
    source   => 'https://github.com/pothiers/data-queue.git',
    revision => "${dataqversion}",
    owner    => 'tada',
    group    => 'tada',
    require  => User['tada'],
    notify   => Exec['install dataq'],
  }

  file { '/usr/local/share/applications/fpack.tgz':
    ensure => 'present',
    replace => false,
    source => "$fpacktgz",
    notify => Exec['unpack fpack'],
  } 
  exec { 'unpack fpack':
    command     => '/bin/tar -xf /usr/local/share/applications/fpack.tgz',
    cwd         => '/usr/local/bin',
    refreshonly => true,
  }

  exec { 'create audit DB':
    command     => '/usr/bin/sqlite3 /var/log/tada/audit.db < /etc/tada/audit-schema.sql;/bin/chmod a+rw /var/log/tada/audit.db',
    onlyif  => "/usr/bin/test ! -f /var/log/tada/audit.db",
    subscribe => File['/etc/tada/audit-schema.sql'],
    } 
#!    exec { 'make audit.db writable by everyone':
#!      command  => '/bin/chmod a+rw /var/log/tada/audit.db',
#!    }
    
  file { '/usr/local/share/applications/irods-3.3.1.tgz':
    ensure => present,
    replace => false,
    source => "$irodstgz",
    notify => Exec['unpack irods'],
  } 
  exec { 'unpack irods':
    command     => '/bin/tar -xf /usr/local/share/applications/irods-3.3.1.tgz',
    cwd         => '/usr/local/share/applications',
    refreshonly => true,
  }
  file { '/usr/local/bin/fitsverify' :
    ensure  => present,
    replace => false,
    source  => 'puppet:///modules/tada/fitsverify',
  }
  # just so LOGROTATE doesn't complain if it runs before we rsync
  file { '/var/log/rsyncd.log' :
    ensure  => present,
    replace => false,
  }
}


