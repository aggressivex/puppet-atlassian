# Class: atlassian::jira::setup
#
# This class installs Jira for CentOS / RHEL
# 
# 
define atlassian::jira::setup (
  $customSetup  = {},
  $customConf   = {},
  $ensure       = installed,
  $boot         = true,
  $status       = 'running',
  $version      = '5.1.5',
  $firewall     = 'iptables',
  $firewallPort = '8080',
) {

  include conf
  $defaultConf = $conf::conf
  $defaultSetup = $conf::setup

  exec { "atlassian-jira-setup-download":
    command => "wget -O /tmp/atlassian-jira-5.1.5.tar.gz http://www.atlassian.com/software/jira/downloads/binary/atlassian-jira-5.1.5.tar.gz",
  }

  file { "/opt/atlassian":
    ensure => "directory",
  }

  file { "/opt/atlassian/home":
    ensure => "directory",
  }

  user { "jira":
    ensure     => "present",
    home       => "/opt/atlassian/jira",
    managehome => true,
    require => File["/opt/atlassian"]    
  }

  exec { "atlassian-jira-setup-decompress":
    command => "tar -C /opt/atlassian/jira -xvf /tmp/atlassian-jira-5.1.5.tar.gz",
    require => User["jira"]
  }

  exec { "atlassian-jira-setup-mv":
    command => "mv /opt/atlassian/jira/atlassian-jira-5.1.5-standalone /opt/atlassian/jira/current",
    require => Exec["atlassian-jira-setup-decompress"]
  }

  exec { "atlassian-jira-setup-start":
    command => "chown -R jira: /opt/atlassian/jira && curl https://raw.github.com/gist/3805534/jira > /etc/init.d/jira && chmod +x /etc/init.d/jira && chkconfig --add jira",
    require => Exec["atlassian-jira-setup-mv"]
  }

  exec { "atlassian-jira-home-env":
    command => "echo JIRA_HOME=\"/opt/atlassian/jira/current/home\" >> /etc/environment && export JIRA_HOME=/opt/atlassian/jira/current/home",
  }

  if ($defaultSetup['setup-mysql']) {
    include mysql

    class { 'mysql::server':
      config_hash => { 
        'root_password' => 'password',
        'bind_address'  => 'UNSET'
      }
    }

    mysql::db { 'atlassian_jira':
      user     => 'admin',
      password => 'password',
      host     => '%',
      grant    => ['all'],
    }

    database_user { 'admin@localhost':
      password_hash => mysql_password('password'),
      require => Database['atlassian_jira']
    }

    database_grant { 'admin@localhost/atlassian_jira':
      privileges => ['all'],
      require => Database_user['admin@localhost']
    }
  }

  case $firewall {
    csf: {
      csf::port::open {'jira-firewall-csf-open':
        port => $port
      }
    }
    iptables: {
      exec { "jira-firewall-iptables-add":
        command => "iptables -I INPUT 5 -p tcp --dport ${firewallPort} -j ACCEPT",
        path    => "/usr/local/bin/:/bin/:/usr/bin/:/usr/sbin:/sbin/",
      }
      exec { "jira-firewall-iptables-save":
        command => "service iptables save",
        path    => "/usr/local/bin/:/bin/:/usr/bin/:/usr/sbin:/sbin/",
        require => Exec["jira-firewall-iptables-add"]
      }
    }
  }
}