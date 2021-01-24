# Class: datashield::packages::libjpeg
# ====================================
#
# Install libjpeg library required for some R packages
#
# Examples
# --------
#
# @example
#    class {datashield::packages::libjpeg,
#    }
#
# Authors
# -------
#
# Stuart Wheater
#

class datashield::packages::libjpeg {

  $libjpeg = $::operatingsystem ? {
    'Ubuntu'  => 'libjpeg-dev',
    'Debian'  => 'libjpeg-dev',
    'CentOS'  => 'libjpeg-devel',
    'RHEL'    => 'libjpeg-devel',
    'Fedora'  => 'libjpeg-devel',
    default => 'libjpeg_dev',
  }

  package { $libjpeg:
    ensure => 'present',
    alias  => 'libjpeg',
  }

}
