# Should contain all of the resources related to getting the software
# the module manages onto the node.
# https://docs.puppetlabs.com/guides/module_guides/bgtm.html

class tada::valley::install (
  $irodstgz    = hiera('irodstgz', 'puppet:///tada/irods-3.3.1.tgz')
  ) {
  file { '/usr/local/share/applications/irods-3.3.1.tgz':
    ensure => present,
    source => "$irodstgz",
    notify => Exec['unpack irods'],
  } 
  exec { 'unpack irods':
    command     => '/bin/tar -xf /usr/local/share/applications/irods-3.3.1.tgz',
    cwd         => '/usr/local/share/applications',
    refreshonly => true,
  }

#!  vcsrepo { '/opt/tada-tools' :
#!    ensure   => latest,
#!    provider => git,
#!    source   => 'https://github.com/pothiers/tada-tools.git',
#!    revision => 'master',
#!  }
  
}
