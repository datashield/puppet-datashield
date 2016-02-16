# Class: datashield::client
# ===========================
#
# Install a datashield client machine without installing any of the server components (e.g. Opal)
#
# Parameters
# ----------
#
# * `rstudio`
# Install rstudio on the client
#
# * `firewall`
# If true, turn on firewall and allow ports for ssh and rstudio
#
# * `create_user`
# True if the user is to be created for rstudio. False if users are managed elsewhere
#
# * `user_name`
# User to be installed on the client for rstudio
#
# * `password_hash`
# Password hash of the user above
#
#
# Examples
# --------
#
# @example
#    class {::datashield::client,
#      firewall => true,
#    }
#
# Authors
# -------
#
# Neil Parley
#

class datashield::client ($rstudio = true, $firewall = true,
  $create_user = true, $user_name = 'datashield', $password_hash = 'mrtyHtvJlH8D2'){

  include ::firewall

  class { ::datashield::r:
    server_side => false
  }

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
    class { datashield::packages::rstudio:
      create_user   => $create_user,
      user_name     => $user_name,
      password_hash => $password_hash
    }
  }

}