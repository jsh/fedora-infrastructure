define glusterfs::client::config(
    $password,
    $servers = [],
    $mountdir = '/gluster',
    $username = 'gluster',
    $owner = 'root',
    $group = 'root',
) {

    include glusterfs::client

#    file { $mountdir:
#        ensure  => directory,
#        recurse => true,
#        owner   => root,
#        group   => root,
#    }

    $conffile = "/etc/glusterfs/glusterfs.${name}.vol"

    file { $conffile:
        owner   => root,
        group   => root,
        mode    => '0644',
        content => template('glusterfs/client.config.erb'),
        notify  => Mount[$::mountpath],
        require => Package['glusterfs-fuse'],
    }

    mount { $mountdir:
        ensure   => mounted,
        atboot   => true,
        device   => $conffile,
        fstype   => 'glusterfs',
        options  => 'noatime',
        require  => [ File[$conffile], File[$::mountpath] ],
        remounts => false,
    }

}
