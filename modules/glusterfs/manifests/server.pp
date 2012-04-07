class glusterfs::server inherits glusterfs::client {

  package { 'glusterfs-server':
    ensure => installed,
  }

  service { 'glusterd':
    ensure     => running,
    enable     => true,
    hasrestart => true,
    hasstatus  => true,
    require    => Package['glusterfs-server']
  }

}

