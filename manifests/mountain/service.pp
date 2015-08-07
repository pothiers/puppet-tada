# Service resources, and anything else related to the running state of
# the software.
# https://docs.puppetlabs.com/guides/module_guides/bgtm.html


class tada::mountain::service (
  $printer  = 'astro',
  $mtncache = hiera('mtncache', '/var/tada/mountain_cache'),
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
    subscribe => [File ['/etc/tada/dqd.conf', '/etc/init.d/dqd'],
                  Class['redis'],
                  Python::Requirements[ '/etc/tada/requirements.txt'],
                  Package['dataq', 'tada'],
                  ],
    ensure    => 'running',
    enable    => true,
    provider  => 'redhat',
    path      => '/etc/init.d',
  }
  
}
