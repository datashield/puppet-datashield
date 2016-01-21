class datashield::packages::rstudio($user_name = 'datashield', $password_hash = 'mrtyHtvJlH8D2') {

  case $::operatingsystem {
    'Ubuntu': {

      include gdebi
      wget::fetch { 'https://download2.rstudio.org/rstudio-server-0.99.491-amd64.deb':
        destination => '/tmp/rstudio-server-0.99.491-amd64.deb',
        timeout     => 0,
        verbose     => false,
      } ->
      package { 'rstudio-server-0.99.491-amd64.deb':
        ensure => 'installed',
        source => '/tmp/rstudio-server-0.99.491-amd64.deb',
        provider => 'gdebi',
        require => Class['::r'],
        alias => 'rstudio',
      }

    }

    'Centos': {
      package { 'rstudio-server':
        ensure => 'installed',
        source => 'https://download2.rstudio.org/rstudio-server-rhel-0.99.491-x86_64.rpm',
        provider => 'rpm',
        require => Class['::r'],
        alias => 'rstudio',
      }
    }

  }

  user { $user_name:
    ensure   => present,
    password => $password_hash,
    notify => Service['rstudio-server'],
    managehome => true,
  }

  service { 'rstudio-server':
    require => Package['rstudio'],
    ensure => running,
    enable => true,
  }

}

