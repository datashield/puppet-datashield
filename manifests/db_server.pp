# Class: datashield::db_server
# ===========================
#
# Installs the MySQL and MongoDB database servers for datashield
#
# Parameters
# ----------
#
#
# * `firewall`
# If true and local_only_access is false, turn on firewall and allow ports for MySQL and/or MongoDB
#
# * `local_only_access`
# If true only allow connection to databases from localhost
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
# * `authentication_database`
# Database used for authentication for mongoDB server
#
# Examples
# --------
#
# @example
#    class {::datashield::db_server:
#      mysql => true,
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
# 'https://github.com/datashield/puppet-datashield'
# 'https://github.com/datashield/puppet-mongodb'
#
# Authors
# -------
#
# Neil Parley
#

class datashield::db_server ($firewall=true, $local_only_access=true,
  $mysql=true, $mysql_root_password='rootpass', $mysql_user='opaluser', $mysql_pass='opalpass',
  $mysql_opal_data_db='opal_data', $mysql_opal_ids_db='opal_ids',
  $mongodb=true, $mongodb_user='opaluser', $mongodb_pass='opalpass', $mongodb_authentication_database='admin') {

  include ::firewall

  if (($firewall) and !($local_only_access)){
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

    if ($mysql) {
      firewall { "330 accept mysql ports":
        proto      => "tcp",
        dport      => [3306],
        action     => "accept",
      }
    }
    if ($mongodb) {
      firewall { "270 accept mongodb ports":
        proto      => "tcp",
        dport      => [27017, 28017],
        action     => "accept",
      }
    }
    firewall { '999 drop all other requests':
      action => 'drop',
    }
  }

  if ($mysql) {

    if ($local_only_access){
      $grant_host = 'localhost'
      class { ::mysql::server:
        restart            => true,
        root_password      => $mysql_root_password,
        config_file        => '/my.cnf',
        create_root_my_cnf => true,
        override_options   => { 'mysqld' =>
        { 'default-storage-engine'  => 'innodb',
          'character-set-server'    => 'utf8', }
        }
      }
    } else {
      $grant_host = '%'
      class { ::mysql::server:
        restart            => true,
        root_password      => $mysql_root_password,
        config_file        => '/my.cnf',
        create_root_my_cnf => true,
        override_options   => { 'mysqld' =>
        { 'default-storage-engine'  => 'innodb',
          'character-set-server'    => 'utf8',
          'bind-address'            => '*' }
        }
      }
    }

    ::mysql::db { $mysql_opal_data_db:
      user     => $mysql_user,
      password => $mysql_pass,
      host     => $grant_host,
      grant    => ['ALL'],
    }

    if !($mongodb) {
      ::mysql::db { $mysql_opal_ids_db:
        user     => $mysql_user,
        password => $mysql_pass,
        host     => $grant_host,
        grant    => ['ALL'],
      }
    }
  }

  if ($mongodb) {
    class { ::mongodb:
      local_only_access       => $local_only_access,
      username                => $mongodb_user,
      password                => $mongodb_pass,
      authentication_database => $mongodb_authentication_database,
    }
  }
}
