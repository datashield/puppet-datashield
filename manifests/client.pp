class datashield::client ($rstudio = true, $firewall = true, $user_name = 'datashield', $password_hash = 'mrtyHtvJlH8D2'){

  include ::firewall

  class {::datashield::r: server_side => false}

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
    if ($rstudio) {
      firewall { "900 accept rstudio ports":
        proto      => "tcp",
        dport      => [8787],
        action     => "accept",
      }
    }
    firewall { '999 drop all other requests':
      action => 'drop',
    }
  }

  if ($rstudio){
    class {datashield::packages::rstudio: user_name => $user_name, password_hash => $password_hash}
  }

}