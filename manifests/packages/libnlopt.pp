# Class: datashield::packages::libnlopt
# =====================================
#
# Install libnlopt library required for some R packages
#
# Examples
# --------
#
# @example
#    class {datashield::packages::libnlopt,
#    }
#
# Authors
# -------
#
# Stuart Wheater
#

class datashield::packages::libnlopt {

  # determine the nlopt package based on operating system,
  $libnlopt = $::operatingsystem ? {
    'Ubuntu'  => 'libnlopt-dev',
    'Debian'  => 'libnlopt-dev',
    'CentOS'  => 'libnlopt-devel',
    'RHEL'    => 'libnlopt-devel',
    'Fedora'  => 'libnlopt-devel',
    default => 'libnlopt_dev',
  }

  package { $libnlopt:
    ensure => 'present',
    alias  => 'libnlopt',
  }

}
