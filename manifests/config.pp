class tada::config {
  $logging_conf=hiera('tada_logging_conf')
  $tada_conf=hiera('tada_conf')
  $date=strftime("%Y-%m-%d")

  $udp_recv_channel = hiera('udp_recv_channel')
  $udp_send_channel = hiera('udp_send_channel')
  $tcp_accept_channel = hiera('tcp_accept_channel')
  
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
    group  => 'root',
    mode   => '0774',
  }
  file { ['/var/log/tada/pop.log', '/var/log/tada/pop-detail.log']:
    ensure => 'present',
    #content => "${date}\n",
    owner  => 'tada',
    group  => 'root',
    mode   => '0774',
  }

  file {  '/etc/tada/tada.conf':
    ensure => 'present',
    source => "${tada_conf}",
    group  => 'root',
    mode   => '0774',
  }
  file { '/etc/tada/pop.yaml':
    ensure => 'present',
    source => "${logging_conf}",
    mode   => '0774',
  }
  file { '/var/log/tada/submit.manifest':
    ensure => 'file',
    owner  => 'tada',
    mode   => '0766',
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


}
