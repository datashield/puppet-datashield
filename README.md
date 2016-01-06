# puppet-datashield

This module gives you the ability to install datashield with puppet. E.g.

  ```ruby 
  class {'::datashield': test_data=false, firewall=true, mysql=true, mongodb=false}
  ```
  
  * test_data: installs test data into the opal database (not implemented) 
  * firewall: installs the firewall and blocks all ports that are not needed by datashield
  * mysql: installs MySQL to be used by opal
  * mongodb: installs MongoDB to be used by opal
