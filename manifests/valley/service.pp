class tada::valley::service {
  service { 'dqd':
    subscribe => [File ['/etc/tada/dqd.conf', '/etc/init.d/dqd'],
                  Class['redis'],
                  Python::Requirements[ '/etc/tada/requirements.txt'],
                  Package['dataq', 'tada'],
                  ],
    ensure   => 'running',
    enable   => true,
    provider => 'redhat',
    path     => '/etc/init.d',
  }
  
}

