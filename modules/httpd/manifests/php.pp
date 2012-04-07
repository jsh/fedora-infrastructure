class httpd::php { #inherits httpd::base {
    package { 'php':
        ensure => installed,
    }

    package { 'php-pecl-apc':
        ensure => installed,
    }

    file { '/etc/php.ini':
        content => template('httpd/php/php.ini.erb'),
        notify  => Service['httpd'],
        require => Package['php'],
    }

    file { '/etc/php.d/apc.ini':
        source  => 'puppet:///httpd/php/apc.ini',
        notify  => Service['httpd'],
        require => Package['php'],
    }

    file { '/srv/web/sessiondata':
        ensure  => directory,
        owner   => 'apache',
        group   => 'apache',
        require => Package['httpd'],
    }
}

