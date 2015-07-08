# Resources related to configuring the installed software 
# https://docs.puppetlabs.com/guides/module_guides/bgtm.html


class tada::config {
  $logging_conf=hiera('tada_logging_conf')
  $tada_conf=hiera('tada_conf')
  
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
  }
  file {  '/etc/tada/tada.conf':
    source => "${tada_conf}",
    #! mode   => '0744',
  }
  file { '/etc/tada/pop.yaml':
    source => "${logging_conf}",
    #! mode   => '0744',
  }
  file { '/var/log/tada/submit.manifest':
    ensure => 'file',
    owner  => 'tada',
    mode   => '0766',
  }
  file { '/etc/tada/requirements.txt':
    source => 'puppet:///modules/tada/requirements.txt',
    }
  file { '/etc/init.d/dqd':
    source => 'puppet:///modules/tada/dqd',
    owner  => 'tada',
    mode   => '0777',
  }

  file_line { 'disable_requiretty':
    path  => '/etc/sudoers',
    line  => '#Defaults    requiretty',
    match => 'Defaults    requiretty',
  }  


  }
