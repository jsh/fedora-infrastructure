class httpd::mod_cache inherits httpd::base {

    file { '/srv/cache':
        ensure  => directory,
        owner   => 'apache',
        group   => 'root',
        mode    => '0750',
        require => Package['httpd'],
    }

    file { '/srv/cache/mod_cache':
        ensure  => directory,
        owner   => 'apache',
        group   => 'root',
        mode    => '0750',
        require => Package['httpd'],
    }

    cron { 'clean-httpd-cache':
        command => '/usr/sbin/htcacheclean -p /srv/cache/mod_cache/ -l 200M | logger -p local0.notice -t httpd',
        user    => 'apache',
        hour    => [ 2, 8, 14, 20 ],
        minute  => [ 15 ],
    }
}

