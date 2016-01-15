class datashield ( $test_data=true, $firewall=true, $mysql=true, $mongodb=true, $change_opal_password=false) {

  # r and datashield / opal packages
  include ::datashield::r
  class {::opal: change_password => $change_opal_password}
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
    mysql::db { 'opal_data':
      user     => 'opaluser',
      password => 'opalpass',
      host     => 'localhost',
      grant    => ['ALL'],
    } ->
    ::opal::db_register {'sqldb': payload => "{\\\"usedForIdentifiers\\\": false, \\\"name\\\": \\\"sqldb\\\", \\\"usage\\\": \\\"STORAGE\\\", \\\"defaultStorage\\\": false, \\\"sqlSettings\\\": {
    \\\"url\\\": \\\"jdbc:mysql://localhost:3306/opal_data\\\", \\\"driverClass\\\": \\\"com.mysql.jdbc.Driver\\\", \\\"username\\\": \\\"opaluser\\\",
    \\\"password\\\": \\\"opalpass\\\", \\\"properties\\\": \\\"\\\", \\\"sqlSchema\\\": \\\"HIBERNATE\\\" }}"}
    if !($mongodb) {
      mysql::db { 'opal_ids':
        user     => 'opaluser',
        password => 'opalpass',
        host     => 'localhost',
        grant    => ['ALL'],
      } -> ::opal::db_register { '_identifiers': payload => "{\\\"usedForIdentifiers\\\": true, \\\"name\\\": \\\"_identifiers\\\", \\\"usage\\\": \\\"STORAGE\\\", \\\"defaultStorage\\\": false, \\\"sqlSettings\\\": {
    \\\"url\\\": \\\"jdbc:mysql://localhost:3306/opal_ids\\\", \\\"driverClass\\\": \\\"com.mysql.jdbc.Driver\\\", \\\"username\\\": \\\"opaluser\\\",
    \\\"password\\\": \\\"opalpass\\\", \\\"properties\\\": \\\"\\\", \\\"sqlSchema\\\": \\\"HIBERNATE\\\" }}"}
    }
  }

  if ($mongodb) {
    class {'::mongodb':} -> ::opal::db_register {'mongodb':
      payload => "{\\\"usedForIdentifiers\\\": false, \\\"name\\\": \\\"mongodb\\\", \\\"usage\\\": \\\"STORAGE\\\",
      \\\"defaultStorage\\\": true, \\\"mongoDbSettings\\\": {\\\"url\\\": \\\"mongodb://localhost:27017/opal_data\\\",
      \\\"username\\\": \\\"\\\", \\\"password\\\": \\\"\\\", \\\"properties\\\": \\\"\\\"}}",
    } -> ::opal::db_register {'_identifiers':
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
        require => Service['opal']
      }
      ::opal::add_project { 'CNSIM':
        payload => "{\\\"name\\\": \\\"CNSIM\\\", \\\"title\\\": \\\"CNSIM\\\", \\\"description\\\": \\\"Simulated data\\\", \\\"database\\\": \\\"mongodb\\\" }",
        require => Service['mongod']
      } ->
      ::opal::import_data {'CNSIM': path => '/home/administrator/testdata/CNSIM/CNSIM.zip', require => File['testdata']}

      ::opal::add_project { 'DASIM':
        payload => "{\\\"name\\\": \\\"DASIM\\\", \\\"title\\\": \\\"DASIM\\\", \\\"description\\\": \\\"Simulated data\\\", \\\"database\\\": \\\"mongodb\\\" }",
        require => Service['mongod']
      } ->
      ::opal::import_data {'DASIM': path => '/home/administrator/testdata/DASIM/DASIM.zip', require => File['testdata']}

      ::opal::add_project { 'SURVIVAL':
        payload => "{\\\"name\\\": \\\"SURVIVAL\\\", \\\"title\\\": \\\"SURVIVAL\\\", \\\"description\\\": \\\"Simulated data\\\", \\\"database\\\": \\\"mongodb\\\" }",
        require => Service['mongod']
      }
    }

  }


}

