class datashield ( $test_data=true, $firewall=true, $mysql=true, $mongodb=true,
  $remote_mongodb=false, $remote_mongodb_url='', $remote_mongodb_user='', $remote_mongodb_pass='',
  $remote_mysql=false, $remote_mysql_url='', $remote_mysql_user='', $remote_mysql_pass='',
  $opal_password='password', $opal_password_hash = '$shiro1$SHA-256$500000$dxucP0IgyO99rdL0Ltj1Qg==$qssS60kTC7TqE61/JFrX/OEk0jsZbYXjiGhR7/t+XNY=') {

  if (($mongodb) and ($remote_mongodb)){
    fail("Remote and local mongodb set")
  }
  if (($mysql) and ($remote_mysql)){
    fail("Remote and local MySQL DB set")
  }

  # r and datashield / opal packages
  class { ::datashield::r: opal_password => $opal_password, require => Class['::opal::install'] }
  class { ::opal: opal_password => $opal_password, opal_password_hash => $opal_password_hash }

  class { ::datashield::packages::openjdk: notify => Package['opal'] }

  include ::firewall

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
      proto   => tcp,
      action  => accept,
    }
    firewall { "900 accept opal ports":
      proto      => "tcp",
      dport      => [8080, 8443],
      action     => "accept",
    }
    firewall { '999 drop all other requests':
      action => 'drop',
    }
  }

  if ($mysql) {
    class { ::mysql::server:
      root_password    => 'rootpass',
      override_options => { 'mysqld' => { 'default-storage-engine' => 'innodb',
        'character-set-server'                                     => 'utf8', } }
    }
    ::mysql::db { 'opal_data':
      user     => 'opaluser',
      password => 'opalpass',
      host     => 'localhost',
      grant    => ['ALL'],
    } ->
    ::opal::database { 'sqldb':
      opal_password      => $opal_password,
      db                 => 'mysql',
      usedForIdentifiers => false,
      url                => 'jdbc:mysql://localhost:3306/opal_data',
      username           => 'opaluser',
      password           => 'opalpass' }
    if !(($mongodb) or ($remote_mongodb)) {
      ::mysql::db { 'opal_ids':
        user     => 'opaluser',
        password => 'opalpass',
        host     => 'localhost',
        grant    => ['ALL'],
      } ->
      ::opal::database { '_identifiers':
        opal_password      => $opal_password,
        db                 => 'mysql',
        usedForIdentifiers => true,
        url                => 'jdbc:mysql://localhost:3306/opal_ids',
        username           => 'opaluser',
        password           => 'opalpass' }
    }
  }

  if ($remote_mysql) {
    ::opal::database { 'sqldb_remote':
      opal_password      => $opal_password,
      db                 => 'mysql',
      usedForIdentifiers => false,
      url                => "jdbc:mysql://${remote_mysql_url}/opal_data",
      username           => $remote_mysql_user,
      password           => $remote_mysql_pass }
    if !(($mongodb) or ($remote_mongodb)) {
      ::mysql::db { 'opal_ids':
        user     => 'opaluser',
        password => 'opalpass',
        host     => 'localhost',
        grant    => ['ALL'],
      } ->
      ::opal::database { '_identifiers':
        opal_password      => $opal_password,
        db                 => mysql,
        usedForIdentifiers => true,
        url                => "jdbc:mysql://${remote_mysql_url}:3306/opal_ids",
        username           => $remote_mysql_user,
        password           => $remote_mysql_pass }
    }
  }

  if ($mongodb) {
    class { ::mongodb: } ->
    ::opal::database { 'mongodb':
      opal_password      => $opal_password,
      db                 => 'mongodb',
      usedForIdentifiers => false,
      defaultStorage     => true,
      url                => 'mongodb://localhost:27017/opal_data'
    } ->
    ::opal::database { '_identifiers':
      opal_password      => $opal_password,
      db                 => 'mongodb',
      usedForIdentifiers => true,
      defaultStorage     => false,
      url                => 'mongodb://localhost:27017/opal_ids'
    }
  }

  if ($remote_mongodb) {
    ::opal::database { 'mongodb_remote':
      opal_password      => $opal_password,
      db                 => 'mongodb',
      username           => $remote_mongodb_user,
      password           => $remote_mongodb_pass,
      usedForIdentifiers => false,
      defaultStorage     => true,
      url                => "mongodb://${remote_mongodb_url}/opal_data"
    }
    ->
    ::opal::database { '_identifiers':
      opal_password      => $opal_password,
      db                 => 'mongodb',
      username           => $remote_mongodb_user,
      password           => $remote_mongodb_pass,
      usedForIdentifiers => true,
      defaultStorage     => false,
      url                => "mongodb://${remote_mongodb_url}/opal_ids"
    }
  }

  if ($test_data) {

    if !($mongodb){
      fail("To use the test data you need mongodb to be installed. Set Mongodb to true")
    }

    if (mongodb) {
      file { "/var/lib/opal/fs/home/administrator/testdata":
        alias   => 'testdata',
        ensure  => directory,
        recurse => true,
        purge   => true,
        force   => true,
        owner   => "opal",
        group   => "adm",
        mode    => '0644',
        source  => "puppet:///modules/datashield/testdata",
        require => Class['::opal::install']
      }
      ::opal::project { 'CNSIM':
        opal_password => $opal_password,
        database      => "mongodb",
        description   => "Simulated data",
      } ->
      ::opal::data { 'CNSIM':
        opal_password => $opal_password,
        path          => '/home/administrator/testdata/CNSIM/CNSIM.zip',
        require       => File['testdata']
      }

      ::opal::project { 'DASIM':
        opal_password => $opal_password,
        database      => "mongodb",
        description   => "Simulated data",
      } ->
      ::opal::data { 'DASIM':
        opal_password => $opal_password,
        path          => '/home/administrator/testdata/DASIM/DASIM.zip',
        require       => File['testdata']
      }

      ::opal::project { 'SURVIVAL':
        opal_password => $opal_password,
        database      => "mongodb",
        description   => "Simulated data",
      } ->
      ::opal::data { 'SURVIVAL':
        opal_password => $opal_password,
        path          => '/home/administrator/testdata/SURVIVAL/SURVIVAL.zip',
        require       => File['testdata']
      }
    }

  }


}

