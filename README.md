# puppet-datashield

#### Table of Contents

1. [Description](#description)
1. [Usage - Configuration options and additional functionality](#usage)
1. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
1. [Limitations - OS compatibility, etc.](#limitations)
1. [Development - Guide for contributing to the module](#development)

## Description

This module gives you the ability to install a datashield server or client with puppet

## Usage

To install a datashield server you need to include the class. By default, both mysql and mongodb will be installed, the
firewall will be turned on and the test data will also be installed. This behavior mimics the behavior of the shell 
provision datashield scripts.

```puppet
class {'::datashield': 
}
```

To create a datashield server with no test data, a mysql database only and the firewall turned off, 
you could include the class as below:

```puppet
class {'::datashield': 
  test_data => false,                            # Don't install the test data
  firewall  => false,                            # Don't install the firewall
  mysql     => true,                             # Install mysql server
  mongodb   => false                             # Don't install mongodb server
}
```

The passwords for the underlining MySQL and MongoDB servers installed can be changed by changing the import password 
variables. For example:

```puppet
class { ::datashield:
  mysql_root_password => 'rootpass',             # Root password for MySQL install
  mysql_user          => 'opaluser',             # MySQL user for Opal databases
  mysql_pass          => 'opalpass',             # MySQL user passport for Opal databases
  mongodb_user        => 'opaluser',             # Username of root MongoDB user for MongoDB install
  mongodb_pass        => 'opalpass',             # Password of root MongoDB user for MongoDB install
}
```

Changing the variables above will change the MySQL root password, user name and password for the Opal MySQL databases, and
the username and password for the root MongoDB user respectively. 

The opal admin password can be changed by the datashield module, by default the module will keep the default opal 
password. To change the password you can send the password and the password hash to the datashield module. 

```puppet
class { '::datashield':
  opal_password      => 'password', 
  opal_password_hash => '$shiro1$SHA-256$500000$dxucP0IgyO99rdL0Ltj1Qg==$qssS60kTC7TqE61/JFrX/OEk0jsZbYXjiGhR7/t+XNY=',
}
```

4 different types of databases can be installed when setting up datashield. The identifier database and test data (if 
being installed) will use the first of the subsequent list being used. 

* Local MongoDB database (`mongodb=true`)
* Local MySQL database (`mysql=true`)
* Remote MongoDB database (`mongodb_remote=true`)
* Remote MySQL database (`mysql_remote=true`)

`mongodb=true` will install a mongodb server, `mysql=true` will install a mysql server, `mongodb_remote=true` will register 
a remote mongodb database with opal and `mysql_remote=true` will register a remote mysql database server with opal. For 
example to use you datashield server with a remote mongodb server you could include the command:

```puppet
class {'::datashield': 
  test_data                   => false,                         # Don't install the test data
  mysql                       => false,                         # Don't install mysql server
  mongodb                     => false                          # Don't install mongodb server
  remote_mongodb              => true,                          # Connect to remote mongodb server
  remote_mongodb_url          => 'mongodb_server.mydomain',     # Remote mongodb server url
  remote_mongodb_user         => 'mongodb_username',            # Username for remote mongodb server
  remote_mongodb_pass         => 'mongodb_password',            # Password for remote mongodb server
  remote_mongodb_opal_data_db => 'opal_data',                   # Name of the database holding Opal data
  remote_mongodb_opal_ids_db  => 'opal_ids',                    # Name of the database holding Opal IDs
  remote_mongodb_auth_db      => 'admin',                       # Database for authenticating mongoDB user
}
```

By default Opal will be installed from the *stable* branch on the Obiba repo and the Datashield server side packages will 
install from the *master* branch. These can be change using the variables below:
 
```puppet
class {'::datashield':
  opal_release         => 'stable',              # The release version of Opal to install.
  r_server_package_ref => 'master'               # Reference (branch) to use for server side R packages
}
```

The datashield module can also be used to provision a database server suitable for datashield with out installing Opal, 
or datashield on the machine. For example:

```puppet
class {'::datashield::db_server':
  firewall            => true,                   # Install firewall on server and open ports
  local_only_access   => false,                  # Allow remote access to the databases
  mysql               => true,                   # Install mysql server
  mysql_root_password => 'rootpass',             # Root password for MySQL install
  mysql_user          => 'opaluser',             # MySQL user for Opal databases
  mysql_pass          => 'opalpass',             # MySQL user passport for Opal databases
  mongodb             => true,                   # Install mongodb server
  mongodb_user        => 'opaluser',             # Username of root MongoDB user for MongoDB install
  mongodb_pass        => 'opalpass',             # Password of root MongoDB user for MongoDB install
}
```

The datashield module can also be used to create a client machine, on which only the datashield client packages are 
installed. This could be used to connect to a remote datashield server with opal and datashield server installed. To
create a datashield client include `::datashield::client`. For example to create a datashield client machine with 
rstudio the below command could be used:
 
```puppet
class {'::datashield::client': 
}
```

This would create a default `datashield` user and password to use with rstudio. A different default user can be given
using the command below, including a password hash to set the users password:
 
```puppet
class {'::datashield::client': 
  user_name     => 'a_user_name', 
  password_hash => 'mrtyHtvJlH8D2'
}
```

## Reference

### datashield

```puppet
class datashield ( $test_data=true, $firewall=true,
  $mysql=true, $mysql_root_password='rootpass', $mysql_user='opaluser', $mysql_pass='opalpass',
  $mysql_opal_data_db='opal_data', $mysql_opal_ids_db='opal_ids',
  $mongodb=true, $mongodb_user='opaluser', $mongodb_pass='opalpass',
  $mongodb_opal_data_db='opal_data', $mongodb_opal_ids_db='opal_ids',
  $remote_mongodb=false, $remote_mongodb_url='', $remote_mongodb_user='', $remote_mongodb_pass='',
  $remote_mongodb_opal_data_db='opal_data', $remote_mongodb_opal_ids_db='opal_ids', $remote_mongodb_auth_db='admin',
  $remote_mysql=false, $remote_mysql_url='', $remote_mysql_user='', $remote_mysql_pass='',
  $remote_mysql_opal_data_db='opal_data', $remote_mysql_opal_ids_db='opal_ids',
  $opal_release = 'stable', $r_server_package_ref='master', 
  $opal_password='password', $opal_password_hash = '$shiro1$SHA-256$500000$dxucP0IgyO99rdL0Ltj1Qg==$qssS60kTC7TqE61/JFrX/OEk0jsZbYXjiGhR7/t+XNY=')
```
Creates a machine as a datashield server. `$test_data` is true to install the datashield test data with Opal. `$firewall` 
installs a fireware on the server machine and only opens the ports required by datashield to operate. `$mysql` installs 
a mysql database server on the machine, similarly `$mongodb` installs a mongodb server on the machine. For the MySQL 
install there are `$mysql_root_password`, `$mysql_user` and `$mysql_pass` variables. These set the root MySQL password 
and create a MySQL user / password for the MySQL opal database creation. For the mongoDB install there are the variables 
`$mongodb_user` and `$mongodb_pass`. These create a user with root access to the mongoDB database server. `$remote_mongodb`
is true if there is a remote mongodb server that opal needs to connect to. `$remote_mongodb_url`, `$remote_mongodb_user`,
`$remote_mongodb_pass` are then the URL, the username and the password of the remote database server. `$remote_mysql`,
`$remote_mysql_url`, `$remote_mysql_user`, `$remote_mysql_pass` are the equivalent for a remote mysql server. `$opal_password` 
and `$opal_password_hash` are the Opal admin password and password hash. See the Opal instructions for creating a password
hash. The name of the databases that hold the Opal data and the Opal IDs can be changed using the `$mongodb_opal_data_db`,
`$mysql_opal_ids_db` etc. variables. By default the Opal data is stored in a database called `opal_data` and the Opal IDs 
are stored in a database called `opal_ids`. `$opal_release` can be changed to change the release version of Opal which is
installed from the package repo, default is stable. `$r_server_package_ref` is the reference i.e. the branch to use for the
R server side package install, default is 'master'.

### datashield::db_server

```puppet
class datashield::db_server ($firewall=true, $local_only_access=true,
  $mysql=true, $mysql_root_password='rootpass', $mysql_user='opaluser', $mysql_pass='opalpass',
  $mysql_opal_data_db='opal_data', $mysql_opal_ids_db='opal_ids',
  $mongodb=true, $mongodb_user='opaluser', $mongodb_pass='opalpass', $mongodb_authentication_database='admin')
```
This installs the MongoDB and MySQL database servers on the machine and sets up the tables needed for Opal. The variables 
are used as described above in the `::datashield` reference. The `datashield::db_server` module can be used to provision 
a database server with out installing Opal, for example to use as a remote database server. `$local_only_access` defines 
if the server should only allow access to the databases from localhost, if the variable is false then remote connections 
will be allowed. If `$local_only_access` is false and `$firewall` is true then a firewall will be turned on and the ports
for MySQL and MongoDB will be opened. `$authentication_database` is the database that mongoDB will use for user authentication.

### datashield::client

```puppet
class datashield::client ($rstudio = true, $firewall = true, $agate=true, $mongodb_user='opaluser', 
  $mongodb_pass='opalpass', $create_user = true, $user_name = 'datashield', $password_hash = 'mrtyHtvJlH8D2')
```
Creates a machine as a datashield client. `$rstudio` is true if rstudio is to be installed on the client machine. If `$agate`
is true the client machine will have the Obiba user management software Agate installed. Agate requires a mongoDB database 
so setting `$agate` to true will also install a MongoDB database server. `$mongodb_user` and `$mongodb_pass` are thus the 
username and password of the root user of this mongoDB install. `firewall` is true if the machine should have a firewall 
install, blocking all ports but those needed to communicate to rstudio. `$user_name` and `$password_hash` are the default 
user and password hash to set up on the machine for logging into rstudio, this user is created if `$create_user` is true, 
if not it is assumed that user management is being done in another file.
  
### datashield::r

```puppet
class datashield::r ($opal_password = 'password', $server_side = true, $server_githubusername = 'datashield', $server_ref = 'master')
```
Installs the datashield R packages and the R packages needed by datashield. `$opal_password` is the admin password for
opal, needed to install the server side R packages. If `$server_side` is true then the server side R packages are installed
if not only the client side packages will be installed. `$server_ref` is the reference (i.e. branch) to use for the R 
server side packages.

### datashield::server_package

```puppet
define datashield::server_package($r_path = '/usr/bin/R', $opal_password = 'password', $opal_url='http://localhost:8080',
  $ref='master') 
```
Datashield server side R package resource. That is will install the the datashield R server side package of name `$name`.
`$r_path` is the path to the R binary, the default is '/usr/bin/R'. `$opal_password` is the opal admin password, 
`$opal_url` is the url of the Opal REST server, default is 'http://localhost:8080'. `$ref` sets the reference (from the
github repo) of the server side package you are installing, default is master. 

### datashield::packages::libcurl

```puppet
class datashield::packages::libcurl
```
Installs the libcurl package, needed by some of the R packages

### datashield::packages::libxml

```puppet
class datashield::packages::libxml
```
Installs the libxml package, needed by some of the R packages

### datashield::packages::openjdk

```puppet
class datashield::packages::openjdk
```
Installs Java openjdk version 8. This is needed by Opal in order to operate without errors in some situations. 

### datashield::packages::openssl

```puppet
class datashield::packages::openssl
```
Installs openssl needed by some of the R packages

### datashield::packages::rstudio

```puppet
class datashield::packages::rstudio($create_user = true, $user_name = 'datashield', $password_hash = 'mrtyHtvJlH8D2')
```
Installs rstudio on the machine and starts the service. If `$create_user` is true then the user `$user_name` is created
with password `$password_hash` to use as rstudio login. If `$create_user` is false then user management is assumed to be
done elsewhere. 
 
## Limitations

Has only been tested on Ubuntu 14.04 and Centos 7. 

## Development

Open source, forks and pull requests welcomed. 

