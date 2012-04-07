class httpd::mod_ssl inherits httpd::base {
    package { 'mod_ssl':
        ensure => installed,
    }

    file { '/etc/httpd/conf.d/ssl.conf':
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        notify  => Service['httpd'],
        require => Package['httpd'],
        source  => 'puppet:///httpd/ssl.conf',
    }
}

