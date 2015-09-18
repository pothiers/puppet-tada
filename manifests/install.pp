
class tada::install (
  $fpacktgz    = hiera('fpacktgz', 'puppet:///modules/tada/fpack-bin-centos-6.6.tgz')
  ) {
  
  $stamp=strftime("%Y-%m-%d %H:%M:%S")
  
  #!exec { 'upgrade-pip':
  #!  command  => '/usr/bin/pip3.4 install --upgrade pip'
  #!}
  

  # these are also given by: puppet-sdm
  include epel
  #!package { ['git', ]: }
  ensure_resource('package', ['git', ], {'ensure' => 'present'})
  
  include augeas
  
  package { ['cups', 'xinetd'] : }
  yumrepo { 'ius':
    descr      => 'ius - stable',
    baseurl    => 'http://dl.iuscommunity.org/pub/ius/stable/CentOS/6/x86_64/',
    enabled    => 1,
    gpgcheck   => 0,
    priority   => 1,
    mirrorlist => absent,
  }
  -> Package<| provider == 'yum' |>

  yumrepo { 'tada':
    descr    => 'tada',
    baseurl  => "http://mirrors.sdm.noao.edu/tada",
    enabled  => 1,
    gpgcheck => 0,
    priority => 1,
    mirrorlist => absent,
  }
  -> Package<| provider == 'yum' |>

  
  package { ['python34u-pip']: }
  class { 'python':
    version    => '34u',
    pip        => false,
    dev        => true,
  } 
  file { '/usr/bin/pip':
    ensure => 'link',
    target => '/usr/bin/pip3.4',
  }

  python::requirements { '/etc/tada/requirements.txt':
    owner  => 'root',
  }
  package{ ['dataq', 'tada'] : }
  
  Class['python'] -> Package['python34u-pip'] -> File['/usr/bin/pip']
  -> Python::Requirements['/etc/tada/requirements.txt']
  -> Package['dataq', 'tada'] 
  -> Service['dqd']
  
  class { 'redis':
    version           => '2.8.19',
    redis_max_memory  => '1gb',
  }
  
  vcsrepo { '/opt/tada-cli' :
    ensure   => latest,
    provider => git,
    source   => 'https://github.com/pothiers/tada-cli.git',
    revision => 'master',
  }

  file { '/usr/local/share/applications/fpack.tgz':
    ensure => present,
    source => "$fpacktgz",
    notify => Exec['unpack fpack'],
  } 
  exec { 'unpack fpack':
    command     => '/bin/tar -xf /usr/local/share/applications/fpack.tgz',
    cwd         => '/usr/local/bin',
    refreshonly => true,
  }
  
}


