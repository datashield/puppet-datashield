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
  test_data => false, 
  firewall  => false, 
  mysql     => true, 
  mongodb   => false
}
```

The opal admin password can be changed by the datashield module, by default the module will keep the default opal 
password. To change the password you can send the password and the password hash to the datashield module. 

```puppet
class { '::datashield':
  opal_password      => 'password', 
  opal_password_hash => '$shiro1$SHA-256$500000$dxucP0IgyO99rdL0Ltj1Qg==$qssS60kTC7TqE61/JFrX/OEk0jsZbYXjiGhR7/t+XNY=',
}
```

4 different types of databases can be installed when setting up datashield. The identifier database and test data (if 
being installed) will use the first in the subsequent list being used. `mongodb=true` will install a mongodb server,
`mongodb_remote=true` will register a remote mongodb database with opal, `mysql=true` will install a mysql server and
`mysql_remote=true` will register a remote mysql database server with opal. For example to use you datashield server
with a remote mongodb server you could include the command:

```puppet
class {'::datashield': 
  test_data           => false, 
  mysql               => false, 
  mongodb             => false
  remote_mongodb      => true, 
  remote_mongodb_url  => 'mongodb_server.mydomain', 
  remote_mongodb_user => 'mongodb_username', 
  remote_mongodb_pass => 'mongodb_password',
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
class datashield ( $test_data=true, $firewall=true, $mysql=true, $mongodb=true,
  $remote_mongodb=false, $remote_mongodb_url='', $remote_mongodb_user='', $remote_mongodb_pass='',
  $remote_mysql=false, $remote_mysql_url='', $remote_mysql_user='', $remote_mysql_pass='',
  $opal_password='password', 
  $opal_password_hash = '$shiro1$SHA-256$500000$dxucP0IgyO99rdL0Ltj1Qg==$qssS60kTC7TqE61/JFrX/OEk0jsZbYXjiGhR7/t+XNY=') 
```
Creates a machine as a datashield server. `$test_data` is true to install the datashield test data with Opal. `$firewall` 
installs a fireware on the server machine and only opens the ports required by datashield to operate. `$mysql` installs 
a mysql database server on the machine, similarly `$mongodb` installs a mongodb server on the machine. `$remote_mongodb`
is true if there is a remote mongodb server that opal needs to connect to. `$remote_mongodb_url`, `$remote_mongodb_user`,
`$remote_mongodb_pass` are then the URL, the username and the password of the remote database server. `$remote_mysql`,
`$remote_mysql_url`, `$remote_mysql_user`, `$remote_mysql_pass` are the equivalent for a remote mysql server. `$opal_password` 
and `$opal_password_hash` are the Opal admin password and password hash. See the Opal instructions for creating a password
hash.

### datashield::client

```puppet
class datashield::client ($rstudio = true, $firewall = true,
  $create_user = true, $user_name = 'datashield', $password_hash = 'mrtyHtvJlH8D2')
```
Creates a machine as a datashield client. `$rstudio` is true if rstudio is to be installed on the client machine. `firewall`
is true if the machine should have a firewall install, blocking all ports but those needed to communicate to rstudio. 
 `$user_name` and `$password_hash` is the default user and password hash to set up on the machine for logging into rstudio,
 this user is created if `$create_user` is true, if not it is assumed that user management is being done in another file.
  
### datashield::r

```puppet
class datashield::r ($opal_password = 'password', $server_side = true)
```
Installs the datashield R packages and the R packages needed by datashield. `$opal_password` is the admin password for
opal, needed to install the server side R packages. If `$server_side` is true then the server side R packages are installed
if not only the client side packages will be installed.

### datashield::server

```puppet
define datashield::server($r_path = '/usr/bin/R', $opal_password = 'password', $opal_url='http://localhost:8080')
```
Datashield server side R package resource. That is will install the the datashield R server side package of name `$name`.
`$r_path` is the path to the R binary, the default is '/usr/bin/R'. `$opal_password` is the opal admin password, 
`$opal_url` is the url of the Opal REST server, default is 'http://localhost:8080'.

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

