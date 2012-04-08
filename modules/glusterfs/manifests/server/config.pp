define glusterfs::server::config(
    $password,
    $datadir = '/srv/glusterfs',
    $username = 'gluster',
    $owner = root,
    $group = root
) {

    include glusterfs::server

    $datapath = "${datadir}/${name}"

    file { $datadir:
        ensure => directory,
        owner  => $owner,
        group  => $group,
    }

    file { $datapath:
        ensure  => directory,
        owner   => $owner,
        group   => $group,
        require => File[$datadir],
    }

    file { "glusterfs_server_${name}":
        name    => '/etc/glusterfs/glusterd.vol',
        owner   => root,
        group   => root,
        mode    => '0644',
        content => template('glusterfs/server.config.erb'),
        notify  => Service['glusterd'],
        require => [ Package['glusterfs-server'], File[$datapath] ],
    }

}
