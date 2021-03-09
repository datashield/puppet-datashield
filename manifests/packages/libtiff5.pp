# Class: datashield::packages::libtiff5
# =====================================
#
# Install libtiff5 library required for some R packages
#
# Examples
# --------
#
# @example
#    class {datashield::packages::libtiff5,
#    }
#
# Authors
# -------
#
# Stuart Wheater
#

class datashield::packages::libtiff5 {

  $libtiff5 = $::operatingsystem ? {
    'Ubuntu'  => 'libtiff5-dev',
    'Debian'  => 'libtiff5-dev',
    'CentOS'  => 'libtiff5-devel',
    'RHEL'    => 'libtiff5-devel',
    'Fedora'  => 'libtiff5-devel',
    default => 'libtiff5_dev',
  }

  package { $libtiff5:
    ensure => 'present',
    alias  => 'libtiff5',
  }

}
