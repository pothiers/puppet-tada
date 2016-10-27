# Service resources, and anything else related to the running state of
# the software.
# https://docs.puppetlabs.com/guides/module_guides/bgtm.html

class tada::service  (
  $cache    = '/var/tada/cache',  
  ) {  

  ## source /opt/tada/venv/bin/activate  

  service { 'dqd':
    ensure   => 'running',
    subscribe => [File ['/etc/tada/dqd.conf',
                        '/etc/init.d/dqd',
                        '/etc/tada/hiera.yaml',
                        '/etc/tada/tada.conf'
                        ],
                  Class['redis'],
                  Python::Requirements[ '/opt/tada/requirements.txt'],
                  #! Package['python-dataq', 'python-tada'],
                  ],
    enable   => true,
    provider => 'redhat',
    path     => '/etc/init.d',
  }
  # WATCH only needed for MOUNTAIN (so far)
  service { 'watchpushd':
    ensure    => 'running',
    subscribe => [File ['/etc/tada/watchpushd.conf',
                        '/etc/init.d/watchpushd'
                        ],
                  Python::Requirements[ '/opt/tada/requirements.txt'],
                  #! Package['python-dataq', 'python-tada']
                  ],
    enable    => true,
    provider  => 'redhat',
    path      => '/etc/init.d',
  }
  
  }
