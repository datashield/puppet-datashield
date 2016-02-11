define datashield::server($r_path = '/usr/bin/R', $opal_password = 'password', $opal_url='http://localhost:8080') {

  include ::r

  exec { "install_datashield_package_${name}":
    command => "${r_path} -e \"library(opaladmin); o<-opal.login('administrator', '${opal_password}', url='${opal_url}'); dsadmin.install_package(o, '${name}'); dsadmin.set_package_methods(o, pkg='${name}')\" | grep 'TRUE' ",
    unless  => "${r_path} -e \"library(opaladmin); o<-opal.login('administrator', '${opal_password}', url='${opal_url}'); dsadmin.installed_package(o, '${name}')\" | grep 'TRUE' ",
    require => [Class['::r'], Class[::opal::install], ::R::Package['opaladmin']]
  }

}