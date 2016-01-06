class datashield::packages::openjdk {

  $openjdk = $::operatingsystem ? {
    'Ubuntu'  => 'openjdk-7-jre',
    'Debian'  => 'openjdk-7-jre',
    'CentOS'  => 'java-1.7.0-openjdk-devel',
    'RHEL'    => 'java-1.7.0-openjdk-devel',
    'Fedora'  => 'java-1.7.0-openjdk-devel',
    default => 'java-1.7.0-openjdk-devel',
  }

  $java_path = $::operatingsystem ? {
    'Ubuntu'  => '/usr/lib/jvm/java-7-openjdk-i386/jre/bin/java',
    'Debian'  => '/usr/lib/jvm/java-7-openjdk-i386/jre/bin/java',
    'CentOS'  => '/usr/lib/jvm/jre-1.7.0-openjdk.x86_64/bin/java',
    'RHEL'    => '/usr/lib/jvm/jre-1.7.0-openjdk.x86_64/bin/java',
    'Fedora'  => '/usr/lib/jvm/jre-1.7.0-openjdk.x86_64/bin/java',
    default => '/usr/lib/jvm/jre-1.7.0-openjdk.x86_64/bin/java',
  }

  package { $openjdk:
    ensure => 'present',
    alias  => 'openjdk',
  }

  alternatives {'java':
    path    => $java_path,
    require => Package['openjdk'],
  }

}