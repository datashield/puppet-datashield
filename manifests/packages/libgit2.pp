# Class: datashield::packages::libgit2
# ====================================
#
# Install libgit2 library required for some R packages
#
# Examples
# --------
#
# @example
#    class {datashield::packages::libgit2,
#    }
#
# Authors
# -------
#
# Stuart Wheater
#

class datashield::packages::libgit2 {

  case $::operatingsystem {
    'Ubuntu': {
      include ::apt
      package { 'software-properties-libgit2':
        ensure  => 'present'
      } ->
      apt::ppa { 'ppa:/cran/libgit2':
        notify => Class['apt::update'],
      }
      ->
      package { 'libgit2-dev':
        ensure  => 'present',
        require =>  Class['apt::update'],
      }
    }
    'Centos': {
      package { 'libgit2':
        ensure  => 'present'
      }
    }
  }
}
