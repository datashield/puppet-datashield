# Type: datashield::server_package
# ===========================
#
# Installs R server side packages using opalr
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
# * `ref`
# The reference to install the server side R functions, default is master
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

define datashield::server_package($r_path = '/usr/bin/R', $opal_password = 'password', $opal_url = 'http://localhost:8080',
  $githubusername = 'datashield', $ref = 'master') {

  include ::r

  exec { "install_datashield_package_${name}":
    command   => "${r_path} -e \"library(opalr); o<-opal.login('administrator', '${opal_password}', url='${opal_url}'); dsadmin.install_package(o, '${name}', profile='default'); dsadmin.remove_package(o, '${name}', profile='default'); dsadmin.install_package(o, '${name}', githubusername='${githubusername}', ref='${ref}', profile='default'); dsadmin.set_package_methods(o, pkg='${name}', profile='default')\" | grep 'TRUE' ",
    unless    => "${r_path} -e \"library(opalr); o<-opal.login('administrator', '${opal_password}', url='${opal_url}'); dsadmin.installed_package(o, '${name}', profile='default')\" | grep 'TRUE' ",
    require   => [Class['::r'], Class[::opal::install], ::R::Package['opalr']],
    tries     => '3',
    try_sleep => '10',
  }

}
