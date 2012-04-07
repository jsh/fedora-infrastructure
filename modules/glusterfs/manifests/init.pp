class glusterfs::server inherits glusterfs::client {

    package { "glusterfs-server":
        ensure => installed,
    }

    service { "glusterd":
	enable => true,
	ensure => running,
	hasrestart => true,
	hasstatus => true,
	require => Package["glusterfs-server"]
    }

}

class glusterfs::client {

    package { "glusterfs-fuse":
        ensure => installed,
    }
}

define glusterfs::server::config(
	$datadir = '/srv/glusterfs',
	$username = 'gluster',
	$password,
	$owner = root,
	$group = root
) {

	include glusterfs::server

	$datapath = "${datadir}/${name}"

	file { "${datadir}":
		ensure => directory,
		owner => $owner,
		group => $group,
	}

	file { "${datapath}":
		ensure => directory,
		owner => $owner,
		group => $group,
		require => File["${datadir}"],
	}

	file { "glusterfs_server_${name}":
		name => "/etc/glusterfs/glusterd.vol",
		owner => root,
		group => root,
		mode => 644,
		content => template("glusterfs/server.config.erb"),
		notify => Service["glusterd"],
		require => [ Package["glusterfs-server"], File["${datapath}"] ],
	}

}
define glusterfs::client::config(
	$servers = [],
	$mountdir = '/gluster',
	$username = 'gluster',
	$password,
	$owner = "root",
	$group = "root"
) {

	include glusterfs::client

#	file { "${mountdir}":
#		ensure => directory,
#                recurse => true,
#		owner => root,
#		group => root,
#	}

	$conffile = "/etc/glusterfs/glusterfs.${name}.vol"

	file { "${conffile}":
		owner => root,
		group => root,
		mode => 644,
		content => template("glusterfs/client.config.erb"),
		notify => Mount["${mountpath}"],
		require => Package["glusterfs-fuse"],
	}

	mount { "${mountdir}":
		atboot => true,
		device => $conffile,
		ensure => mounted,
		fstype => "glusterfs",
		options => "noatime",
		require => [ File["${conffile}"], File["${mountpath}"] ],
		remounts => false,
	}

}
