class datashield ( $test_data=false, $firewall=true, $mysql=true, $mongodb=false ) {

  # r and datashield / opal packages
  include 'datashield::r'
  include '::opal'
  include 'firewall'

  if ($firewall){
    Firewall {
      require => undef,
    }
    # Default firewall rules
    firewall { '000 accept all icmp':
      proto   => 'icmp',
      action  => 'accept',
    }
    firewall { '001 accept all to lo interface':
      proto   => 'all',
      iniface => 'lo',
      action  => 'accept',
    }
    firewall { '002 accept related established rules':
      proto   => 'all',
      state   => ['RELATED', 'ESTABLISHED'],
      action  => 'accept',
    }
    firewall { '100 allow ssh access':
      dport   => '22',
      proto  => tcp,
      action => accept,
    }
    firewall { "900 accept opal ports":
      proto     => "tcp",
      dport      => [8080, 8443],
      action    => "accept",
    }
    firewall { '999 drop all other requests':
      action => 'drop',
    }
  }

  if ($mysql) {
    class { '::mysql::server':
      root_password    => 'rootpass',
      override_options => { 'mysqld' => { 'default-storage-engine' => 'innodb',
        'default-character-set'  => 'utf8',
        'default-collation' => 'utf8_bin'} }
    }
    mysql::db { 'opal_data':
      user     => 'opaluser',
      password => 'opalpass',
      host     => 'localhost',
      grant    => ['ALL'],
    }
    mysql::db { 'opal_ids':
      user     => 'opaluser',
      password => 'opalpass',
      host     => 'localhost',
      grant    => ['ALL'],
    }
  }

  if ($mongodb) {
    include '::mongodb::server'
  }

}