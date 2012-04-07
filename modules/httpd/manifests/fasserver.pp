class httpd::fasserver inherits httpd::base {
    File['/etc/httpd/conf/httpd.conf'] {
        source => 'puppet:///module/httpd/httpd.conf.fas',
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

