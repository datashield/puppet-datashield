# Class: datashield::packages::libmagickpp
# ========================================
#
# Install libmagick++ library required for some R packages
#
# Examples
# --------
#
# @example
#    class {datashield::packages::libmagickpp,
#    }
#
# Authors
# -------
#
# Stuart Wheater
#

class datashield::packages::libmagickpp {

  case $::operatingsystem {
    'Ubuntu': {
      include ::apt
      apt::ppa { 'ppa:/cran/imagemagick':
        notify => Class['apt::update'],
      }
      ->
      package { 'libmagick++-dev':
        ensure  => 'present',
        require =>  Class['apt::update'],
      }
    }
    'Centos': {
      package { 'libmagick++':
        ensure  => 'present'
      }
    }
  }
}
