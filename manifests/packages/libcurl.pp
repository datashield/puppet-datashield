# Class: datashield::packages::libcurl
# ===========================
#
# Install libcurl library required for some R packages
#
# Examples
# --------
#
# @example
#    class {datashield::packages::libcurl,
#    }
#
# Authors
# -------
#
# Neil Parley
#

class datashield::packages::libcurl {

  # determine the curl package based on operating syste,
  $libcurl = $::operatingsystem ? {
    'Ubuntu'  => 'libcurl4-openssl-dev',
    'Debian'  => 'libcurl4-openssl-dev',
    'CentOS'  => 'libcurl-devel',
    'RHEL'    => 'libcurl-devel',
    'Fedora'  => 'libcurl-devel',
    default => 'libcurl_dev',
  }

  package { $libcurl:
    ensure => 'present',
    alias  => 'libcurl',
  }

}