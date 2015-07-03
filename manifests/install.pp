# Should contain all of the resources related to getting the software
# the module manages onto the node.
# https://docs.puppetlabs.com/guides/module_guides/bgtm.html

class tada::install {
  # these are also given by: puppet-sdm
  #! include epel
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
    } -> Package<| provider == 'yum' |>
    
    package { ['python34u-pip']: }
    class { 'python':
      version    => '34u',
      pip        => false,
      dev        => true,
      #!virtualenv => true,
    } 
    file { '/usr/bin/pip':
      ensure => 'link',
      target => '/usr/bin/pip3.4',
    }
    
    python::requirements { '/etc/tada/requirements.txt': } 
    
    Class['python'] -> Package['python34u-pip'] -> File['/usr/bin/pip']
    -> Python::Requirements['/etc/tada/requirements.txt']

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
}


