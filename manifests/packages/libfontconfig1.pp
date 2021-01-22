# Class: datashield::packages::libfontconfig1
# ===========================================
#
# Install libfontconfig1 library required for some R packages
#
# Examples
# --------
#
# @example
#    class {datashield::packages::libfontconfig1,
#    }
#
# Authors
# -------
#
# Stuart Wheater
#

class datashield::packages::libfontconfig1 {

  $libfontconfig1 = $::operatingsystem ? {
    'Ubuntu'  => 'libfontconfig1-dev',
    'Debian'  => 'libfontconfig1-dev',
    'CentOS'  => 'libfontconfig1-devel',
    'RHEL'    => 'libfontconfig1-devel',
    'Fedora'  => 'libfontconfig1-devel',
    default => 'libfontconfig1_dev',
  }

  package { $libfontconfig1:
    ensure => 'present',
    alias  => 'libfontconfig1',
  }

}
