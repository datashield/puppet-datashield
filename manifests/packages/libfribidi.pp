# Class: datashield::packages::libfribidi
# =======================================
#
# Install libfribidi library required for some R packages
#
# Examples
# --------
#
# @example
#    class {datashield::packages::libfribidi,
#    }
#
# Authors
# -------
#
# Stuart Wheater
#

class datashield::packages::libfribidi {

  $libfribidi = $::operatingsystem ? {
    'Ubuntu'  => 'libfribidi-dev',
    'Debian'  => 'libfribidi-dev',
    'CentOS'  => 'libfribidi-devel',
    'RHEL'    => 'libfribidi-devel',
    'Fedora'  => 'libfribidi-devel',
    default => 'libfribidi_dev',
  }

  package { $libfribidi:
    ensure => 'present',
    alias  => 'libfribidi',
  }

}
