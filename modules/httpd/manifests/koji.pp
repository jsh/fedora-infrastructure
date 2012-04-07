class httpd::koji inherits httpd::base {
    File['/etc/httpd/conf/httpd.conf'] {
        source => 'puppet:///httpd/httpd.conf-koji',
    }

    file { '/etc/httpd/conf.d/headers.conf':
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        content => template('httpd/koji-headers.conf.erb'),
        notify  => Service['httpd'],
        require => Package['httpd'],
    }
}

