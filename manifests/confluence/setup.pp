# Class: webmin::setup
#
# This class installs webmin for CentOS / RHEL
#
define atlassian::confluence::setup (
  $customSetup  = {},
  $customConf   = {},
  $ensure       = installed,
  $boot         = true,
  $status       = 'running',
  $firewall     = false,
  $firewallPort = '8008',
) {

  include conf
  $defaultConf = $conf::conf
  $defaultSetup = $conf::setup

  # yumrepo { "webmin":
  #   baseurl  => "http://download.webmin.com/download/yum",
  #   descr    => "Webmin Distribution Neutral",
  #   enabled  => 1,
  #   gpgcheck => 0,
  # }

  # package { 'webmin':
  #   ensure => "present",
  #   require => Yumrepo["webmin"]
  # }

  # service { 'webmin':
  #   name       => 'webmin',
  #   ensure     => $status,
  #   enable     => $boot,
  #   hasrestart => true,
  #   hasstatus  => true,
  #   require    => Package ['webmin']
  # }

  # case $firewall {
  #   csf: {
  #     csf::port::open {'webmin-firewall-csf-open':
  #       port => $port
  #     }
  #   }
  #   iptables: {
  #     exec { "webmin-firewall-iptables-add":
  #       command => "iptables -I INPUT 5 -p tcp --dport ${firewallPort} -j ACCEPT",
  #       path    => "/usr/local/bin/:/bin/:/usr/bin/:/usr/sbin:/sbin/",
  #       require => Package["webmin"]
  #     }
  #     exec { "webmin-firewall-iptables-save":
  #       command => "service iptables save",
  #       path    => "/usr/local/bin/:/bin/:/usr/bin/:/usr/sbin:/sbin/",
  #       require => Exec["webmin-firewall-iptables-add"]
  #     }
  #   }
  # }
}