class httpd::mod_wsgi inherits httpd::base {
    package { 'mod_wsgi':
        ensure => installed,
    }

    file { '/etc/httpd/conf.d/wsgi.conf':
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        notify  => Service['httpd'],
        require => Package['httpd'],
        source  => 'puppet:///module/httpd/wsgi.conf',
    }
}

