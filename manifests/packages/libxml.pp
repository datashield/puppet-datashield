class datashield::packages::libxml {

  $libxml = $::operatingsystem ? {
    'Ubuntu'  => 'libxml2-dev',
    'Debian'  => 'libxml2-dev',
    'CentOS'  => 'libxml2-devel',
    'RHEL'    => 'libxml2-devel',
    'Fedora'  => 'libxml2-devel',
    default => 'libxml2_dev',
  }

  package { $libxml:
    ensure => 'present',
    alias  => 'libxml',
  }

}