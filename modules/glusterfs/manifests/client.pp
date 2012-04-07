class glusterfs::client {

  package { 'glusterfs-fuse':
    ensure => installed,
  }
}

