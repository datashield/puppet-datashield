# Class: datashield::packages::rstudio
# ===========================
#
# Install rstudio, start the rstudio service and create a user for use with rstudio
#
# Parameters
# ----------
#
# * `create_user`
# True if the user is to be created. False if users are managed elsewhere
#
# * `user_name`
# User to be installed on the client for rstudio
#
# * `password_hash`
# Password hash of the user above
#
# Examples
# --------
#
# @example
#    class {datashield::packages::rstudio,
#      user_name     => $user_name,
#      password_hash => $password_hash
#    }
#
# Authors
# -------
#
# Neil Parley
#

class datashield::packages::rstudio($create_user = true, $user_name = 'datashield', $password_hash = 'mrtyHtvJlH8D2') {

  case $::operatingsystem {
    'Ubuntu': {

      include gdebi
      wget::fetch { 'https://download2.rstudio.org/rstudio-server-0.99.491-amd64.deb':
        destination => '/tmp/rstudio-server-0.99.491-amd64.deb',
        timeout     => 0,
        verbose     => false,
      } ->
      package { 'rstudio-server-0.99.491-amd64.deb':
        ensure   => 'installed',
        source   => '/tmp/rstudio-server-0.99.491-amd64.deb',
        provider => 'gdebi',
        require  => Class['::r'],
        alias    => 'rstudio',
      }

    }

    'Centos': {
      package { 'rstudio-server':
        ensure   => 'installed',
        source   => 'https://download2.rstudio.org/rstudio-server-rhel-0.99.491-x86_64.rpm',
        provider => 'rpm',
        require  => Class['::r'],
        alias    => 'rstudio',
      }
    }

  }

  if ($create_user){
    user { $user_name:
      ensure     => present,
      password   => $password_hash,
      notify     => Service['rstudio-server'],
      managehome => true,
    }
  }

  service { 'rstudio-server':
    require => Package['rstudio'],
    ensure  => running,
    enable  => true,
  }

}

