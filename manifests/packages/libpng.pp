# Class: datashield::packages::libpng
# ===================================
#
# Install libpng library required for some R packages
#
# Examples
# --------
#
# @example
#    class {datashield::packages::libpng,
#    }
#
# Authors
# -------
#
# Neil Parley
#

class datashield::packages::libpng {

  $libpng = $::operatingsystem ? {
    'Ubuntu'  => 'libpng-dev',
    'Debian'  => 'libpng-dev',
    'CentOS'  => 'libpng-devel',
    'RHEL'    => 'libpng-devel',
    'Fedora'  => 'libpng-devel',
    default => 'libpng_dev',
  }

  package { $libpng:
    ensure => 'present',
    alias  => 'libpng',
  }

}
