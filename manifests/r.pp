class datashield::r ($opal_password = 'password', $server_side = true) {
  include datashield::packages::libcurl
  include datashield::packages::libxml
  include datashield::packages::openssl
  include ::r

  Class['datashield::packages::libcurl'] ->
  ::r::package { 'datashieldclient':
    repo         => ['http://cran.obiba.org', 'http://cran.rstudio.com'],
    dependencies => true,
    require      => Class['::r'],
  }

  Class['datashield::packages::libxml', 'datashield::packages::openssl'] ->
  ::r::package { 'opaladmin':
    repo         => ['http://cran.obiba.org', 'http://cran.rstudio.com'],
    dependencies => true,
    require      => Class['::r'],
  }

  ::r::package { 'devtools': dependencies => true, }
  ::r::package { 'testthat': dependencies => true, }

  if ($server_side){
    ::opal::datashield_server { 'dsBase': opal_password => $opal_password, require => ::R::Package['opaladmin'] }
    ::opal::datashield_server { 'dsStats': opal_password => $opal_password, require => ::R::Package['opaladmin'] }
    ::opal::datashield_server { 'dsGraphics': opal_password => $opal_password, require => ::R::Package['opaladmin'] }
    ::opal::datashield_server { 'dsModelling': opal_password => $opal_password, require => ::R::Package['opaladmin'] }
  }
}