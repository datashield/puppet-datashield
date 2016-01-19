class datashield::r {
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

  ::opal::datashield_install {'dsBase': require => Exec['install_r_package_opaladmin']}
  ::opal::datashield_install {'dsStats': require => Exec['install_r_package_opaladmin']}
  ::opal::datashield_install {'dsGraphics': require => Exec['install_r_package_opaladmin']}
  ::opal::datashield_install {'dsModelling': require => Exec['install_r_package_opaladmin']}

}