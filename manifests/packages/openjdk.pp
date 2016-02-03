class datashield::packages::openjdk {

  case $::operatingsystem {
    'Ubuntu': {
      include ::apt
      package {'software-properties-common': ensure  => 'present'} ->
      apt::ppa { 'ppa:openjdk-r/ppa': notify => Class['apt::update'],}
      ->
      package { 'openjdk-8-jre':
        ensure  => 'present',
        require =>  Class['apt::update'],
        alias   => 'java8'
      }
      -> alternatives {'java':
        path  => '/usr/lib/jvm/java-8-openjdk-amd64/jre/bin/java'
      }
    }
    'Centos': {
      package { 'java-1.8.0-openjdk':
        ensure  => 'present',
        alias   => 'java8'
      }
    }
  }

  # $java_path = $::operatingsystem ? {
  #   'Ubuntu'  => '/usr/lib/jvm/java-7-openjdk-i386/jre/bin/java',
  #   'Debian'  => '/usr/lib/jvm/java-7-openjdk-i386/jre/bin/java',
  #   'CentOS'  => '/usr/lib/jvm/jre-1.7.0-openjdk.x86_64/bin/java',
  #   'RHEL'    => '/usr/lib/jvm/jre-1.7.0-openjdk.x86_64/bin/java',
  #   'Fedora'  => '/usr/lib/jvm/jre-1.7.0-openjdk.x86_64/bin/java',
  #   default => '/usr/lib/jvm/jre-1.7.0-openjdk.x86_64/bin/java',
  # }
  #
  # alternatives {'java':
  #   path    => $java_path,
  #   require => Package['openjdk'],
  # }

}