
class tada::install (
  $fpacktgz    = hiera('fpacktgz', 'puppet:///modules/tada/fpack-bin-centos-6.6.tgz'),
  $irodstgz    = hiera('irodstgz', 'puppet:///tada/irods-3.3.1.tgz'),
  $tadaversion = hiera('tadaversion', 'master'),
  $dataqversion = hiera('dataqversion', 'master'),
  ) {
  notice("Loading tada::install; tadaversion=${tadaversion}, dataqversion=${dataqversion}")

  # Top-level dependency to support full tada re-provision
  # To force re-provision: "rm /opt/tada-release" on BOTH mtn and valley
  $stamp=strftime("%Y-%m-%d %H:%M:%S")
  exec { 'provision tada':
    path    => '/usr/bin:/usr/sbin:/bin',
    command => "rm -rf /etc/tada/ /var/log/tada /var/run/tada /home/tada/.tada /home/tada/.irods /home/tester/.tada /home/tester/.irods",
    onlyif => 'test \! -f /opt/tada-release',
    } ->
   file { '/opt/tada-release':
    ensure  => 'present',
    replace => false,
    content => "$stamp
",
    notify  => [File[#'/var/tada', # do NOT change history on reprovision!
                     '/etc/tada',
                     '/var/log/tada',
                     '/var/run/tada',
                     '/home/tada/.tada',
                     '/home/tada/.irods',
                     '/home/tester/.tada',
                     '/home/tester/.irods'
                     ],
                Vcsrepo['/opt/tada',
                        '/opt/tada-cli',
                        '/opt/data-queue'
                        ]
                ]
  }
  
  # these are also given by: puppet-sdm
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


  # These install tada,dataq,dart from source in /opt/tada,data-queue,dart
  exec { 'install dataq':
    cwd     => '/opt/data-queue',
    command => "/bin/bash -c  /opt/data-queue/scripts/dataq-valley-install.sh",
    #creates => '/opt/tada/venv/bin/dqsvcpop',
    refreshonly  => true,
    logoutput    => true,
    #user    => 'tada',
    notify  => [Service['watchpushd'], Service['dqd'], ],
    subscribe => [
      Vcsrepo['/opt/data-queue'], 
      File['/opt/tada/venv', '/etc/tada/hiera.yaml'],
      Python::Requirements['/opt/tada/requirements.txt'],
    ],
  } ->
  exec { 'install tada':
    cwd          => '/opt/tada',
    command      => "/bin/bash -c /opt/tada/scripts/tada-valley-install.sh",
    refreshonly  => true,
    logoutput    => true,
    #!user         => 'tada',
    notify       => [Service['watchpushd'], Service['dqd'], ],
    subscribe    => [
                     Vcsrepo['/opt/tada'], 
                     File['/opt/tada/venv'], 
                     File['/etc/tada/hiera.yaml'],
                     Python::Requirements['/opt/tada/requirements.txt'],
                     ],
  } #! ->
  #!exec { 'install dart':
  #!  cwd     => '/opt/dart',
  #!  command      => "/bin/bash -c /opt/dart/scripts/dart-valley-install.sh",
  #!  creates => '/opt/tada/venv/bin/delete_archived_fits',
  #!  #~user    => 'tada',
  #!  subscribe => [
  #!    Vcsrepo['/opt/dart'], 
  #!    File['/opt/tada/venv'],
  #!    Python::Requirements['/opt/dart/requirements.txt'],
  #!  ],
  #!}

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
    group    => 'tada',
    require  => [ User['tada'], ],
  } ->
  python::requirements  { '/opt/tada/requirements.txt':
    virtualenv => '/opt/tada/venv',
    owner      => 'tada',
    group      => 'tada',
    require    => [ User['tada'], ],
    }->
  #!python::requirements  { '/opt/dart/requirements.txt':
  #!  virtualenv => '/opt/tada/venv',
  #!  owner      => 'tada',
  #!  group      => 'tada',
  #!  require    => [ User['tada'], Vcsrepo['/opt/dart'] ],
  #!}->
  python::pip { 'pylint' :
   pkgname    => 'pylint',
   ensure     => 'latest',
   virtualenv => '/opt/tada/venv',   
   owner      => 'tada',
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
  group { 'tada':
    ensure => 'present',
  } -> 
  user { 'tada' :
    ensure     => 'present',
    comment    => 'For running TADA related services and actions',
    managehome => true,
    password   => '$1$Pk1b6yel$tPE2h9vxYE248CoGKfhR41',  # tada"Password"
    system     => true,
    } #! ->
#!  file { '/home/tada/.ssh':
#!      ensure  => directory,
#!      mode    => '0700',
#!      } ->
#!  file { '/home/tada/.ssh/id_rsa':
#!    ensure  => 'present',
#!    mode    => '0600',
#!    source  => 'puppet:///modules/dmo_hiera/tada_id_rsa',
#!    } ->
#!  file { '/home/tada/.ssh/id_rsa.pub':
#!    ensure  => 'present',
#!    mode    => '0644',
#!    source  => 'puppet:///modules/dmo_hiera/tada_id_rsa.pub',
#!  }
  user { 'tester' :
    ensure     => 'present',
    comment    => 'For running TADA related tests',
    managehome => true,
    password   => '$1$Pk1b6yel$tPE2h9vxYE248CoGKfhR41',  # tada"Password"
    groups     => ['tada'],
    system     => false,
  } 
  vcsrepo { '/opt/tada' :
    ensure   => latest,
    provider => git,
    source   => 'https://github.com/pothiers/tada.git',
    revision => "${tadaversion}",
    owner    => 'tada', # 'tester', # 'tada',
    group    => 'tada',
    require  => User['tada'],
    notify   => Exec['install tada'],
    } ->
#!  vcsrepo { '/opt/dart' :
#!    ensure   => latest,
#!    provider => git,
#!    #!source   => 'https://pothier@bitbucket.org/noao/dart.git',
#!    #!source   => 'https://github.com/NOAO/dart.git',
#!    source   => 'git@github.com:NOAO/dart.git',
#!    revision => 'master',
#!    owner    => 'tada', # 'tester', # 'tada',
#!    group    => 'tada',
#!    identity => '/home/tada/.ssh/id_rsa',
#!    require  => User['tada'],
#!    notify   => Exec['install dart'],
#!    } ->
  file { '/opt/tada/tests/smoke':
      ensure  => directory,
      mode    => '0774',
      recurse => true,
      }
  vcsrepo { '/opt/data-queue' :
    ensure   => latest,
    provider => git,
    source   => 'https://github.com/pothiers/data-queue.git',
    revision => "${dataqversion}",
    owner    => 'tada', # 'tester', #'tada',
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
  file { '/usr/local/bin/fitscopy' :
    ensure  => present,
    replace => false,
    source  => 'puppet:///modules/tada/fitscopy',
  }
  # just so LOGROTATE doesn't complain if it runs before we rsync
  file { '/var/log/rsyncd.log' :
    ensure  => present,
    replace => false,
  }

#!  # Install the public key in authorized_keys
#!  ssh_authorized_key { 'tada_id_rsa':
#!    key  => hiera('tadakey'),
#!    type => 'ssh-rsa',
#!    user => 'tada',
#!  }
}


