# Class: datashield::r
# ===========================
#
# Installs R and all the R packages required for datashield
#
# Parameters
# ----------
#
# * `opal_password`
# Admin password for opal (required to installed the datashield server packages)
#
# * `server_side`
# If true (defualt) datashield server and client R packages are install, if false just client packages are installed
#
# * `server_ref`
# The reference to use for the server side R packages, default is 'master'
#
# Examples
# --------
#
# @example
#    class { ::datashield::r:
#      opal_password => $opal_password,
#    }
#
# Authors
# -------
#
# Neil Parley
#

class datashield::r ($opal_password = 'password', $server_side = true,
                     $dsbase_githubusername = 'datashield', $dsbase_ref = 'master',
                     $dsdanger_githubusername = 'datashield', $dsdanger_ref = 'master') {
  include datashield::packages::libcurl
  include datashield::packages::libxml
  include datashield::packages::openssl
  include datashield::packages::libmagickpp
  include datashield::packages::libfontconfig1
  include datashield::packages::libfreetype6
  include datashield::packages::libpng
  include datashield::packages::libtiff5
  include datashield::packages::libjpeg
  include datashield::packages::libfribidi
  include datashield::packages::libharfbuzz
  include datashield::packages::libgit2
  include ::r

  Class['datashield::packages::libxml', 'datashield::packages::openssl', 'datashield::packages::libmagickpp', 'datashield::packages::libfontconfig1', 'datashield::packages::libfreetype6',
        'datashield::packages::libpng', 'datashield::packages::libtiff5', 'datashield::packages::libjpeg', 'datashield::packages::libfribidi', 'datashield::packages::libharfbuzz', 
        'datashield::packages::libgit2'] ->
  ::r::package { 'opalr':
    repo         => ['http://cran.obiba.org', 'http://cran.rstudio.com'],
    dependencies => true,
    require      => Class['::r'],
  }

  ::r::package { 'Rserve':
    dependencies => true,
  }
  ::r::package { 'credentials':
    dependencies => true,
  }
  ::r::package { 'gert':
    dependencies => true,
  }
  ::r::package { 'usethis':
    dependencies => true,
  }
  ::r::package { 'devtools':
    dependencies => true,
  }
  ::r::package { 'testthat':
    dependencies => true,
  }
  ::r::package { 'readr':
    dependencies => true,
  }

  ::r::package { 'RANN':
    dependencies => true,
  }
  ::r::package { 'nlme':
    dependencies => true,
  }
  ::r::package { 'stringr':
    dependencies => true,
  }
  ::r::package { 'lme4':
    dependencies => true,
  }
  ::r::package { 'ggplot2':
    dependencies => true,
  }
  ::r::package { 'dplyr':
    dependencies => true,
  }
  ::r::package { 'reshape2':
    dependencies => true,
  }

  if ($server_side){
    if ($dsbase_ref != ''){
      datashield::server_package { 'dsBase':
        opal_password  => $opal_password,
        githubusername => $dsbase_githubusername,
        ref            => $dsbase_ref
      }
    }
    if ($dsdanger_ref != ''){
      datashield::server_package { 'dsDanger':
        opal_password  => $opal_password,
        githubusername => $dsdanger_githubusername,
        ref            => $dsdanger_ref
      }
    }
  }
}
