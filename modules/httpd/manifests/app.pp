class httpd::app inherits httpd::base {
    File['/etc/httpd/conf/httpd.conf'] {
        source => 'puppet:///module/httpd/httpd.conf-rhel5app',
    }

    file { '/etc/httpd/conf.d/headers.conf':
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        content => template('httpd/app-headers.conf.erb'),
        notify  => Service['httpd'],
        require => Package['httpd'],
    }
}

