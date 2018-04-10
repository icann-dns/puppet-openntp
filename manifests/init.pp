# = Class: openntp
#
class openntp (
  Boolean                                          $enable,
  Array[Stdlib::Host]                              $server,
  String                                           $package,
  String                                           $service,
  String                                           $owner,
  String                                           $group,
  Stdlib::Absolutepath                             $config_file,
  String                                           $template,
  Optional[Variant[Enum['*'], Stdlib::Ip_address]] $listen = undef,
) {

  ensure_packages([$package])
  if $::facts['os']['id'] == 'Ubuntu' {
    # https://bugs.launchpad.net/ubuntu/+source/openntpd/+bug/458061
    package {'ntp':
      ensure => purged,
      before => Package[$package],
    }
    exec { 'reload app armor':
      command     => '/usr/sbin/service apparmor reload',
      onlyif      => '/usr/bin/test -x /sbin/apparmor_parser',
      refreshonly => true,
      subscribe   => Package['ntp'],
      before      => Package[$package],
    }
  }
  file {$config_file:
    ensure  => file,
    content => template($template),
    owner   => $owner,
    group   => $group,
    mode    => '0644',
    require => Package[$package],
  }
  service {$service:
    ensure  => $enable,
    enable  => $enable,
    require => [Package[$package], File[$config_file]],
  }
}
