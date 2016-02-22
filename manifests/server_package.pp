# Type: datashield::server_package
# ===========================
#
# Installs R server side packages using opaladmin
#
# Parameters
# ----------
#
# * `r_path`
# Path to the R binary, default is '/usr/bin/R'
#
# * `opal_password`
# Admin password for opal (required to installed the datashield server packages)
#
# * `opal_url`
# Url of the opal REST server, default is 'http://localhost:8080'
#
#
# Examples
# --------
#
# @example
#    ::datashield::server_package { 'dsBase':
#      opal_password => $opal_password
#    }
#
# Authors
# -------
#
# Neil Parley
#

define datashield::server_package($r_path = '/usr/bin/R', $opal_password = 'password', $opal_url='http://localhost:8080') {

  include ::r

  exec { "install_datashield_package_${name}":
    command => "${r_path} -e \"library(opaladmin); o<-opal.login('administrator', '${opal_password}', url='${opal_url}'); dsadmin.install_package(o, '${name}'); dsadmin.set_package_methods(o, pkg='${name}')\" | grep 'TRUE' ",
    unless  => "${r_path} -e \"library(opaladmin); o<-opal.login('administrator', '${opal_password}', url='${opal_url}'); dsadmin.installed_package(o, '${name}')\" | grep 'TRUE' ",
    require => [Class['::r'], Class[::opal::install], ::R::Package['opaladmin']]
  }

}