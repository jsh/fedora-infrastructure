class httpd::base {
    include logrotate

    package { 'httpd':
        ensure => installed,
    }

    service { 'httpd':
        ensure    => running,
        enable    => true,
        hasstatus => true,
        restart   => '/sbin/service httpd graceful',
        require   => Package['httpd'],
    }

    if $::operatingsystemrelease >= 6 {
        semanage_fcontext { '/srv/web(/.*)?':
            type => 'httpd_sys_content_t'
        }
    }

    file { '/etc/httpd/conf/httpd.conf':
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        source  => 'puppet:///httpd/httpd.conf',
        notify  => Service['httpd'],
        require => Package['httpd'],
    }

    file { '/srv/web':
        ensure => directory,
        owner  => 'root',
        group  => 'root',
        mode   => '0755',
    }

    # This is disabled on releng2 and relepel1 as bodhi runs
    # mash in a thread which gets killed on an httpd reload
    file { '/etc/logrotate.d/httpd':
        ensure   => $::hostname ? {
            releng2  => absent,
            relepel1 => absent,
            default  => file,
        }
        owner    => 'root',
        group    => 'root',
        mode     => '0644',
        source   => 'puppet:///httpd/httpd.logrotate',
        require  => Package['httpd'],
    }
}

