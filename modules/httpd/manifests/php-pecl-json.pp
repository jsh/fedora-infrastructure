class httpd::php-pecl-json {
    package { 'php-pecl-json':
        ensure => installed,
    }

    file { '/etc/php.d/json.ini':
        source  => 'puppet:///httpd/php/json.ini',
        notify  => Service['httpd'],
        require => Package['php'],
    }
}

# This is a temporary class to get the nagios interface working
# while we move over to Zabbix.
