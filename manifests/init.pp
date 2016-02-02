class datashield ( $test_data=true, $firewall=true, $mysql=true, $mongodb=true,
  $opal_password='password', $opal_password_hash = '$shiro1$SHA-256$500000$dxucP0IgyO99rdL0Ltj1Qg==$qssS60kTC7TqE61/JFrX/OEk0jsZbYXjiGhR7/t+XNY=') {

  # r and datashield / opal packages
  class {::datashield::r: opal_password => $opal_password, require => Class['::opal::install']}
  class {::opal: opal_password => $opal_password, opal_password_hash => $opal_password_hash}
  include ::firewall
  class {::datashield::packages::openjdk: notify => Package['opal']}

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
        'character-set-server' => 'utf8',} }
    }
    ::mysql::db { 'opal_data':
      user     => 'opaluser',
      password => 'opalpass',
      host     => 'localhost',
      grant    => ['ALL'],
    } ->
    ::opal::db_register {'sqldb': opal_password => $opal_password, payload => "{\\\"usedForIdentifiers\\\": false, \\\"name\\\": \\\"sqldb\\\", \\\"usage\\\": \\\"STORAGE\\\", \\\"defaultStorage\\\": false, \\\"sqlSettings\\\": {
    \\\"url\\\": \\\"jdbc:mysql://localhost:3306/opal_data\\\", \\\"driverClass\\\": \\\"com.mysql.jdbc.Driver\\\", \\\"username\\\": \\\"opaluser\\\",
    \\\"password\\\": \\\"opalpass\\\", \\\"properties\\\": \\\"\\\", \\\"sqlSchema\\\": \\\"HIBERNATE\\\" }}"}
    if !($mongodb) {
      ::mysql::db { 'opal_ids':
        user     => 'opaluser',
        password => 'opalpass',
        host     => 'localhost',
        grant    => ['ALL'],
      } -> ::opal::db_register { '_identifiers': opal_password => $opal_password, payload => "{\\\"usedForIdentifiers\\\": true, \\\"name\\\": \\\"_identifiers\\\", \\\"usage\\\": \\\"STORAGE\\\", \\\"defaultStorage\\\": false, \\\"sqlSettings\\\": {
    \\\"url\\\": \\\"jdbc:mysql://localhost:3306/opal_ids\\\", \\\"driverClass\\\": \\\"com.mysql.jdbc.Driver\\\", \\\"username\\\": \\\"opaluser\\\",
    \\\"password\\\": \\\"opalpass\\\", \\\"properties\\\": \\\"\\\", \\\"sqlSchema\\\": \\\"HIBERNATE\\\" }}"}
    }
  }

  if ($mongodb) {
    class {'::mongodb':} -> ::opal::db_register {'mongodb': opal_password => $opal_password,
      payload => "{\\\"usedForIdentifiers\\\": false, \\\"name\\\": \\\"mongodb\\\", \\\"usage\\\": \\\"STORAGE\\\",
      \\\"defaultStorage\\\": true, \\\"mongoDbSettings\\\": {\\\"url\\\": \\\"mongodb://localhost:27017/opal_data\\\",
      \\\"username\\\": \\\"\\\", \\\"password\\\": \\\"\\\", \\\"properties\\\": \\\"\\\"}}",
    } -> ::opal::db_register {'_identifiers': opal_password => $opal_password,
      payload => "{\\\"usedForIdentifiers\\\": true, \\\"name\\\": \\\"_identifiers\\\", \\\"usage\\\": \\\"STORAGE\\\",
      \\\"defaultStorage\\\": false, \\\"mongoDbSettings\\\": {\\\"url\\\": \\\"mongodb://localhost:27017/opal_ids\\\",
      \\\"username\\\": \\\"\\\", \\\"password\\\": \\\"\\\", \\\"properties\\\": \\\"\\\"}}",
    }
  }

  if ($test_data) {

    if !($mongodb){
      fail("To use the test data you need mongodb to be installed. Set Mongodb to true")
    }

    if (mongodb) {
      file { "/var/lib/opal/fs/home/administrator/testdata":
        alias => 'testdata',
        ensure => directory,
        recurse => true,
        purge => true,
        force => true,
        owner => "opal",
        group => "adm",
        mode => '0644',
        source => "puppet:///modules/datashield/testdata",
        require => [Class['::opal::install'], ] # Exec['register_db__identifiers']
      }
      ::opal::add_project { 'CNSIM': opal_password => $opal_password,
        payload => "{\\\"name\\\": \\\"CNSIM\\\", \\\"title\\\": \\\"CNSIM\\\", \\\"description\\\": \\\"Simulated data\\\", \\\"database\\\": \\\"mongodb\\\" }",
        require => Service['mongod']
      } ->
      ::opal::import_data {'CNSIM': opal_password => $opal_password, path => '/home/administrator/testdata/CNSIM/CNSIM.zip', require => File['testdata']}

      ::opal::add_project { 'DASIM': opal_password => $opal_password,
        payload => "{\\\"name\\\": \\\"DASIM\\\", \\\"title\\\": \\\"DASIM\\\", \\\"description\\\": \\\"Simulated data\\\", \\\"database\\\": \\\"mongodb\\\" }",
        require => Service['mongod']
      } ->
      ::opal::import_data {'DASIM': opal_password => $opal_password, path => '/home/administrator/testdata/DASIM/DASIM.zip', require => File['testdata']}

      ::opal::add_project { 'SURVIVAL': opal_password => $opal_password,
        payload => "{\\\"name\\\": \\\"SURVIVAL\\\", \\\"title\\\": \\\"SURVIVAL\\\", \\\"description\\\": \\\"Simulated data\\\", \\\"database\\\": \\\"mongodb\\\" }",
        require => Service['mongod']
      } ->
      ::opal::import_data {'SURVIVAL': opal_password => $opal_password, path => '/home/administrator/testdata/SURVIVAL/SURVIVAL.zip', require => File['testdata']}
    }

  }


}

