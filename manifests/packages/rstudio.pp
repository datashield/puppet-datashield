class datashield::packages::rstudio {


  case $::operatingsystem {
    'Ubuntu': {

      package { 'gdebi-core':  ensure => 'installed', } ->
      package { 'rstudio':
        ensure => 'installed',
        source => 'https://download2.rstudio.org/rstudio-server-0.99.491-amd64.deb',
        provider => 'deb',
        require => '::r',
      } ~>
      service { 'rstudio-server':
        ensure => running,
        enable => true,
      }

    }

    'Centos': {

      package { 'rstudio':
        ensure => 'installed',
        source => 'https://download2.rstudio.org/rstudio-server-rhel-0.99.491-x86_64.rpm',
        provider => 'rpm',
        require => '::r',
      } ~>
      service { 'rstudio-server':
        ensure => running,
        enable => true,
      }
    }

  }
}

