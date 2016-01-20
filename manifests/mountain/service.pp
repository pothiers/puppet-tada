# Service resources, and anything else related to the running state of
# the software.
# https://docs.puppetlabs.com/guides/module_guides/bgtm.html


class tada::mountain::service (
  $printer  = 'astro',
  $mtncache = '/var/tada/cache',
  ) {
  service { 'cups':
    ensure    => 'running',
    enable    => true,
    require   => Package['cups'],
    subscribe => File['/etc/cups/cupsd.conf',
                      '/usr/lib/cups/lib/astro/pushfile.sh',
                      '/usr/lib/cups/backend/astropost'],
  } 
  
  exec { 'add-astro-printer':
    subscribe   => Service['cups'],
    refreshonly => true,
    command     => "/usr/sbin/lpadmin -p ${printer} -v astropost:${mtncache} -E",
  }

  service { 'dqd':
    ensure    => 'running',
    subscribe => [File ['/etc/tada/dqd.conf', '/etc/init.d/dqd'],
                  Class['redis'],
                  Python::Requirements[ '/etc/tada/requirements.txt'],
                  Package['dataq', 'tada'],
                  ],
    enable    => true,
    provider  => 'redhat',
    path      => '/etc/init.d',
  }
  
  service { 'watchpushd':
    ensure    => 'running',
    subscribe => [File ['/etc/tada/watchpushd.conf', '/etc/init.d/watchpushd'],
                  Python::Requirements[ '/etc/tada/requirements.txt'],
                  Package['dataq', 'tada'],
                  ],
    enable    => true,
    provider  => 'redhat',
    path      => '/etc/init.d',
  }
  
}
