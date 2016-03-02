# Class: datashield
# ===========================
#
# Install and manage datashield and it's requirements on a system.
#
# Parameters
# ----------
#
# * `opal_password`
# The admin password for managing opal
#
# * `opal_password_hash`
# The opal admin password hash to set the opal admin password
#
# * `firewall`
# If true, turn on firewall and allow ports for Opal and datashield to be openned.
#
# * `mysql`
# If true install mysql on the datashield server
#
# * `mysql_root_password`
# The root password for the MySQL install
#
# * `mysql_user`
# The MySQL user for the opal data / id databases
#
# * `mysql_pass`
# The MySQL user password for the opal data / id databases
#
# * `mysql_opal_data_db`
# The name of the database to hold the opal data for the MySQL install
#
# * `mysql_opal_ids_db`
# The name of the database to hold the opal ids for the MySQL install
#
# * `mongodb`
# If true install mongodb on the datashield server, the _identifiers database will use mongodb by default
#
# * `mongodb_user`
# The mongoDB root user name
#
# * `mongodb_pass`
# The mongoDB root user name's password
#
# * `mongodb_opal_data_db`
# The name of the database to hold the opal data for the MongoDB install
#
# * `mongodb_opal_ids_db`
# The name of the database to hold the opal ids for the MongoDB install
#
# * `remote_mongodb`
# If true use a remote mongodb database server datashield server
#
# * `remote_mongodb_url`
# URL of the remote mongodb server (used if remote_mongodb is true)
#
# * `remote_mongodb_user`
# Username for the remote mongodb server (used if remote_mongodb is true)
#
# * `remote_mongodb_pass`
# Password for the remote mongodb server (used if remote_mongodb is true)
#
# * `remote_mongodb_opal_data_db`
# The name of the database to hold the opal data for the remote MongoDB server
#
# * `remote_mongodb_opal_ids_db`
# The name of the database to hold the opal ids for the remote MongoDB server
#
# * `remote_mongodb_auth_db`
# The authorization database for the remote MongoDB server
#
# * `remote_mysql`
# If true use a remote mysql database server datashield server
#
# * `remote_mysql_url`
# URL of the remote mysql server (used if remote_mysql is true)
#
# * `remote_mysql_user`
# Username for the remote mysql server (used if remote_mysql is true)
#
# * `remote_mysql_pass`
# Password for the remote mysql server (used if remote_mysql is true)
#
# * `remote_mysql_opal_data_db`
# The name of the database to hold the opal data for the remote MySQL server
#
# * `remote_mysql_opal_ids_db`
# The name of the database to hold the opal ids for the remote MySQL server
#
# * `test_data`
# Installs the test data with the opal install
#
# Examples
# --------
#
# @example
#    class {::datashield:
#      firewall => false,
#    }
#
# Requires
# -------
#
# 'puppetlabs/stdlib', '4.9.0'
# 'puppetlabs/apt', '2.2.0'
# 'stahnma/epel', '1.1.1'
# 'nanliu/staging', '1.0.3'
# 'puppetlabs/mysql', '3.6.1'
# 'adrien/alternatives', '0.3.0'
# 'puppetlabs/firewall', '1.7.2'
# 'basti1302/wait_for', '0.3.0'
# 'https://github.com/datashield/puppet-opal'
# 'https://github.com/datashield/puppet-r'
# 'https://github.com/datashield/puppet-datashield'
# 'https://github.com/datashield/puppet-mongodb'
#
# Authors
# -------
#
# Neil Parley
#

class datashield ( $test_data=true, $firewall=true,
  $mysql=true, $mysql_root_password='rootpass', $mysql_user='opaluser', $mysql_pass='opalpass',
  $mysql_opal_data_db='opal_data', $mysql_opal_ids_db='opal_ids',
  $mongodb=true, $mongodb_user='opaluser', $mongodb_pass='opalpass',
  $mongodb_opal_data_db='opal_data', $mongodb_opal_ids_db='opal_ids',
  $remote_mongodb=false, $remote_mongodb_url='', $remote_mongodb_user='', $remote_mongodb_pass='',
  $remote_mongodb_opal_data_db='opal_data', $remote_mongodb_opal_ids_db='opal_ids', $remote_mongodb_auth_db='admin',
  $remote_mysql=false, $remote_mysql_url='', $remote_mysql_user='', $remote_mysql_pass='',
  $remote_mysql_opal_data_db='opal_data', $remote_mysql_opal_ids_db='opal_ids',
  $opal_password='password', $opal_password_hash = '$shiro1$SHA-256$500000$dxucP0IgyO99rdL0Ltj1Qg==$qssS60kTC7TqE61/JFrX/OEk0jsZbYXjiGhR7/t+XNY=') {

  $remote_mongodb_ids = $remote_mongodb
  $remote_mysql_ids = $remote_mysql

  if (($mongodb) and ($remote_mongodb)){
    $remote_mongodb_ids = false
  }

  if (($mysql) and ($remote_mysql)){
    $remote_mysql_ids = false
  }

  # r and datashield / opal packages
  class { ::datashield::r:
    opal_password => $opal_password,
    require       => Class['::opal::install']
  }
  class { ::opal:
    opal_password      => $opal_password,
    opal_password_hash => $opal_password_hash
  }

  class { ::datashield::packages::openjdk:
    notify => Package['opal']
  }

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

  class { datashield::db_server:
    mysql                => $mysql,
    mysql_root_password  => $mysql_root_password,
    mysql_user           => $mysql_user,
    mysql_pass           => $mysql_pass,
    mysql_opal_data_db   => $mysql_opal_data_db,
    mysql_opal_ids_db    => $mysql_opal_ids_db,
    mongodb              => $mongodb,
    mongodb_user         => $mongodb_user,
    mongodb_pass         => $mongodb_pass
  }

  if ($mysql) {
    ::opal::database { 'sqldb':
      opal_password      => $opal_password,
      db_type            => 'mysql',
      usedForIdentifiers => false,
      url                => "jdbc:mysql://localhost:3306/${mysql_opal_data_db}",
      username           => $mysql_user,
      password           => $mysql_pass,
      require            => Class[datashield::db_server]
    }
    # If no MongoDB use MySQL for IDs
    if !($mongodb) {
      ::opal::database { '_identifiers':
        opal_password      => $opal_password,
        db_type            => 'mysql',
        usedForIdentifiers => true,
        url                => "jdbc:mysql://localhost:3306/${mysql_opal_ids_db}",
        username           => $mysql_user,
        password           => $mysql_pass,
        require            => Class[datashield::db_server]
      }
    }
  }

  if ($remote_mysql) {
    ::opal::database { 'sqldb_remote':
      opal_password      => $opal_password,
      db_type            => 'mysql',
      usedForIdentifiers => false,
      url                => "jdbc:mysql://${remote_mysql_url}/${remote_mysql_opal_data_db}",
      username           => $remote_mysql_user,
      password           => $remote_mysql_pass }

    # mongodb == False -> Means no local MongoDB installed
    # remote_mongodb_ids == False -> thus means no remote mongoDB installed
    # remote_mysql_ids == True -> means no local MySQL installed
    if (!($remote_mongodb_ids) and !($mongodb) and ($remote_mysql_ids)) {
      ::opal::database { '_identifiers':
        opal_password      => $opal_password,
        db_type            => 'mysql',
        usedForIdentifiers => true,
        url                => "jdbc:mysql://${remote_mysql_url}/${remote_mysql_opal_ids_db}",
        username           => $remote_mysql_user,
        password           => $remote_mysql_pass }
    }
  }

  if ($mongodb) {
    ::opal::database { 'mongodb':
      opal_password      => $opal_password,
      db_type            => 'mongodb',
      username           => $mongodb_user,
      password           => $mongodb_pass,
      usedForIdentifiers => false,
      defaultStorage     => true,
      url                => "mongodb://localhost:27017/${mongodb_opal_data_db}?authSource=admin",
      require            => Class[datashield::db_server]
    } -> # Use MongoDB by default
    ::opal::database { '_identifiers':
      opal_password      => $opal_password,
      db_type            => 'mongodb',
      username           => $mongodb_user,
      password           => $mongodb_pass,
      usedForIdentifiers => true,
      defaultStorage     => false,
      url                => "mongodb://localhost:27017/${mongodb_opal_ids_db}?authSource=admin",
      require            => Class[datashield::db_server]
    }
  }

  if ($remote_mongodb) {
    ::opal::database { 'mongodb_remote':
      opal_password      => $opal_password,
      db_type            => 'mongodb',
      username           => $remote_mongodb_user,
      password           => $remote_mongodb_pass,
      usedForIdentifiers => false,
      defaultStorage     => false,
      url                => "mongodb://${remote_mongodb_url}/${remote_mongodb_opal_data_db}?authSource=${remote_mongodb_auth_db}"
    }
    # If $remote_mongodb_ids == True then local mongodb not installed. If $mysql == False then local MySQL not installed.
    if (($remote_mongodb_ids) and !($mysql)) {
      ::opal::database { '_identifiers':
        opal_password      => $opal_password,
        db_type            => 'mongodb',
        username           => $remote_mongodb_user,
        password           => $remote_mongodb_pass,
        usedForIdentifiers => true,
        defaultStorage     => false,
        url                => "mongodb://${remote_mongodb_url}/${remote_mongodb_opal_ids_db}?authSource=${remote_mongodb_auth_db}"
      }
    }
  }

  if ($test_data) {

    # Put test data in the first of Local MongoDB, Local MySQL, Remote MongoDB, Remote MySQL
    if ($mongodb) and !($test_db){
      $test_db = "mongodb"
    }
    if ($mysql) and !($test_db){
      $test_db = "sqldb"
    }
    if ($remote_mongodb) and !($test_db){
      $test_db = "mongodb_remote"
    }
    if ($remote_mysql) and !($test_db){
      $test_db = "sqldb_remote"
    }
    if !($test_db) {
      fail("No database for test data")
    }

    if ($test_db) {
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
        database      => $test_db,
        description   => "Simulated data",
      } ->
      ::opal::data { 'CNSIM':
        opal_password => $opal_password,
        path          => '/home/administrator/testdata/CNSIM/CNSIM.zip',
        require       => File['testdata']
      }

      ::opal::project { 'DASIM':
        opal_password => $opal_password,
        database      => $test_db,
        description   => "Simulated data",
      } ->
      ::opal::data { 'DASIM':
        opal_password => $opal_password,
        path          => '/home/administrator/testdata/DASIM/DASIM.zip',
        require       => File['testdata']
      }

      ::opal::project { 'SURVIVAL':
        opal_password => $opal_password,
        database      => $test_db,
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

