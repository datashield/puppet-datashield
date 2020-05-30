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
                     $dsstats_githubusername = 'datashield', $dsstats_ref = 'master',
                     $dsgraphics_githubusername = 'datashield', $dsgraphics_ref = 'master',
                     $dsmodelling_githubusername = 'datashield', $dsmodelling_ref = 'master') {
  include datashield::packages::libcurl
  include datashield::packages::libxml
  include datashield::packages::openssl
  include ::r

  Class['datashield::packages::libxml', 'datashield::packages::openssl'] ->
  ::r::package { 'opalr':
    repo         => ['http://cran.obiba.org', 'http://cran.rstudio.com'],
    dependencies => true,
    require      => Class['::r'],
  }

  ::r::package { 'Rserve':
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

  if ($server_side){
    if ($dsbase_ref != ''){
      datashield::server_package { 'dsBase':
        opal_password  => $opal_password,
        githubusername => $dsbase_githubusername,
        ref            => $dsbase_ref
      }
    }
    if ($dsstats_ref != ''){
      datashield::server_package { 'dsStats':
        opal_password  => $opal_password,
        githubusername => $dsstats_githubusername,
        ref            => $dsstats_ref
      }
    }
    if ($dsgraphics_ref != ''){
      datashield::server_package { 'dsGraphics':
        opal_password  => $opal_password,
        githubusername => $dsgraphics_githubusername,
        ref            => $dsgraphics_ref
      }
    }
    if ($dsmodelling_ref != ''){
      datashield::server_package { 'dsModelling':
        opal_password  => $opal_password,
        githubusername => $dsmodelling_githubusername,
        ref            => $dsmodelling_ref
      }
    }
  }
}
