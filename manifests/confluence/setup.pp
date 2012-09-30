# Class: webmin::setup
#
# This class installs webmin for CentOS / RHEL
# @TODO unattended install https://confluence.atlassian.com/display/DOC/Installing+Confluence+on+Linux
# 
define atlassian::confluence::setup (
  $customSetup  = {},
  $customConf   = {},
  $ensure       = installed,
  $boot         = true,
  $status       = 'running',
  $firewall     = false,
  $firewallPort = '8090',
) {

  include conf
  $defaultConf = $conf::conf
  $defaultSetup = $conf::setup


  # wget -O /tmp/atlassian-confluence-4.3.1-x64.bin http://www.atlassian.com/software/confluence/downloads/binary/atlassian-confluence-4.3.1-x64.bin
  # chmod a+x /tmp/atlassian-confluence-4.3.1-x64.bin -q -varfile response.varfile

  case $firewall {
    csf: {
      csf::port::open {'confluence-firewall-csf-open':
        port => $port
      }
    }
    iptables: {
      exec { "confluence-firewall-iptables-add":
        command => "iptables -I INPUT 5 -p tcp --dport ${firewallPort} -j ACCEPT",
        path    => "/usr/local/bin/:/bin/:/usr/bin/:/usr/sbin:/sbin/",
      }
      exec { "confluence-firewall-iptables-save":
        command => "service iptables save",
        path    => "/usr/local/bin/:/bin/:/usr/bin/:/usr/sbin:/sbin/",
        require => Exec["confluence-firewall-iptables-add"]
      }
    }
  }
}