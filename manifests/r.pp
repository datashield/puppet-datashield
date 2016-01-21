class datashield::r ($opal_password = 'password', $server_side = true) {
  include datashield::packages::libcurl
  include datashield::packages::libxml
  include datashield::packages::openssl
  include ::r

  Class['datashield::packages::libcurl'] -> ::r::package { 'datashieldclient':
    repo => ['http://cran.obiba.org', 'http://cran.rstudio.com'], dependencies => true, require => Class['::r'],
  }
  Class['datashield::packages::libxml', 'datashield::packages::openssl'] -> ::r::package {
    'opaladmin': repo => ['http://cran.obiba.org', 'http://cran.rstudio.com'], dependencies => true,
      require => Class['::r'],
  }

  ::r::package { 'devtools': dependencies => true,}
  ::r::package { 'testthat': dependencies => true,}

  if ($server_side){
    ::opal::datashield_install { 'dsBase': opal_password => $opal_password, require => Exec['install_r_package_opaladmin'] }
    ::opal::datashield_install { 'dsStats': opal_password => $opal_password, require => Exec['install_r_package_opaladmin'] }
    ::opal::datashield_install { 'dsGraphics': opal_password => $opal_password, require => Exec['install_r_package_opaladmin'] }
    ::opal::datashield_install { 'dsModelling': opal_password => $opal_password, require => Exec['install_r_package_opaladmin'] }
  }
}