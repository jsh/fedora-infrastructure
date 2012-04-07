class  httpd::newbase {

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
        source  => "puppet:///httpd/httpd.conf.${::distrorelease}",
        notify  => Service['httpd'],
        require => Package['httpd'],
    }

    file { '/srv/web':
        ensure => directory,
        owner  => 'root',
        group  => 'root',
        mode   => '0755',
    }

    file { '/srv/web/robots.txt.lockbox01':
        owner  => 'root',
        group  => 'root',
        mode   => '0644',
        source => 'puppet:///httpd/robots/robots.txt.lockbox01',
    }
}

