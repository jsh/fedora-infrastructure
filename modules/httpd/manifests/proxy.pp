class httpd::proxy inherits httpd::base {
    File['/etc/httpd/conf/httpd.conf'] {
        source => 'puppet:///httpd/httpd.conf-rhel5p',
    }

    file { '/etc/httpd/conf.d/00-namevirtualhost.conf':
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        source  => 'puppet:///httpd/00-namevirtualhost.conf',
        notify  => Service['httpd'],
        require => Package['httpd'],
    }

    file { '/etc/httpd/conf.d/01-keepalives.conf':
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        source  => 'puppet:///httpd/01-keepalives.conf',
        notify  => Service['httpd'],
        require => Package['httpd'],
    }

    file { '/etc/httpd/conf.d/welcome.conf':
        ensure  => absent,
        notify  => Service['httpd'],
        require => Package['httpd'],
    }

    file { '/etc/httpd/conf.d/headers.conf':
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        content => template('httpd/proxy-headers.conf.erb'),
        notify  => Service['httpd'],
        require => Package['httpd'],
    }
}

