class datashield::packages::openssl {

  $openSSL = $::operatingsystem ? {
    'Ubuntu'  => 'libssl-dev',
    'Debian'  => 'libssl-dev',
    'CentOS'  => 'openssl-devel',
    'RHEL'    => 'openssl-devel',
    'Fedora'  => 'openssl-devel',
    default => 'openssl-devel',
  }

  package { $openSSL:
    ensure => 'present',
    alias  => 'openSSL',
  }

}