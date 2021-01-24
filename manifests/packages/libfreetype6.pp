# Class: datashield::packages::libfreetype6
# =========================================
#
# Install libfreetype6 library required for some R packages
#
# Examples
# --------
#
# @example
#    class {datashield::packages::libfreetype6,
#    }
#
# Authors
# -------
#
# Stuart Wheater
#

class datashield::packages::libfreetype6 {

  $libfreetype6 = $::operatingsystem ? {
    'Ubuntu'  => 'libfreetype6-dev',
    'Debian'  => 'libfreetype6-dev',
    'CentOS'  => 'libfreetype6-devel',
    'RHEL'    => 'libfreetype6-devel',
    'Fedora'  => 'libfreetype6-devel',
    default => 'libfreetype6_dev',
  }

  package { $libfreetype6:
    ensure => 'present',
    alias  => 'libfreetype6',
  }

}
