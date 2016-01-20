class datashield::packages::rstudio {


  case $::operatingsystem {
    'Ubuntu': {

      include gdebi
      wget::fetch { 'https://download2.rstudio.org/rstudio-server-0.99.491-amd64.deb':
        destination => '/tmp/rstudio-server-0.99.491-amd64.deb',
        timeout     => 0,
        verbose     => false,
      } ->
      package { 'rstudio':
        ensure => 'installed',
        source => '/tmp/rstudio-server-0.99.491-amd64.deb',
        provider => 'gdebi',
        require => Class['::r'],
      }

    }

    'Centos': {

      package { 'rstudio':
        ensure => 'installed',
        source => 'https://download2.rstudio.org/rstudio-server-rhel-0.99.491-x86_64.rpm',
        provider => 'rpm',
        require => Class['::r'],
      }
    }

  }

  user { 'datashield':
    ensure   => present,
    password => 'mrtyHtvJlH8D2',
    notify => Service['rstudio-server'],
    managehome => true,
  }

  service { 'rstudio-server':
    require => Package['rstudio'],
    ensure => running,
    enable => true,
  }

}

