# Class: datashield::packages::libharfbuzz
# ========================================
#
# Install libharfbuzz library required for some R packages
#
# Examples
# --------
#
# @example
#    class {datashield::packages::libharfbuzz,
#    }
#
# Authors
# -------
#
# Stuart Wheater
#

class datashield::packages::libharfbuzz {

  $libharfbuzz = $::operatingsystem ? {
    'Ubuntu'  => 'libharfbuzz-dev',
    'Debian'  => 'libharfbuzz-dev',
    'CentOS'  => 'libharfbuzz-devel',
    'RHEL'    => 'libharfbuzz-devel',
    'Fedora'  => 'libharfbuzz-devel',
    default => 'libharfbuzz_dev',
  }

  package { $libharfbuzz:
    ensure => 'present',
    alias  => 'libharfbuzz',
  }

}
