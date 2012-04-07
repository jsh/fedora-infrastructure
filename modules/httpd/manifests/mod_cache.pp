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

    $httpd::mod_cache::ccleancmd = '/usr/sbin/htcacheclean -p /srv/cache/mod_cache/ -l 200M',
    $httpd::mod_cache::logcmd =  'logger -p local0.notice -t httpd',

    cron { 'clean-httpd-cache':
        command => "${httpd::mod_cache::ccleancmd} | ${httpd::mod_cache::logercmd}",
        user    => 'apache',
        hour    => [ 2, 8, 14, 20 ],
        minute  => [ 15 ],
    }
}

