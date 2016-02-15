# Class: datashield::packages::openjdk
# ===========================
#
# Install openjdk Java 8; required for opal to work without errors
#
# Examples
# --------
#
# @example
#    class {datashield::packages::openjdk,
#    }
#
# Authors
# -------
#
# Neil Parley
#

class datashield::packages::openjdk {

  case $::operatingsystem {
    'Ubuntu': {
      include ::apt
      package { 'software-properties-common':
        ensure  => 'present'
      } ->
      apt::ppa { 'ppa:openjdk-r/ppa':
        notify => Class['apt::update'],
      }
      ->
      package { 'openjdk-8-jre':
        ensure  => 'present',
        require =>  Class['apt::update'],
        alias   => 'java8'
      }
      -> alternatives { 'java':
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
}