define httpd::website(
    $ips = [],
    $server_aliases = [],
    $server_admin = 'webmaster@fedoraproject.org',
    $ssl = false,
    $sslonly = false,
    $cert_name  = '',
    $sSLCertificateChainFile = '',
) {
    file { "/etc/httpd/conf.d/$name":
        ensure  => directory,
        owner   => 'root',
        group   => 'root',
        mode    => '0755',
        require => $ssl ? {
            false   => Package['httpd'],
            default => [
                Package['httpd'],
                Httpd::Certificate[$cert_name],
            ],
        },
    }

    file { "/etc/httpd/conf.d/$name.conf":
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        content => template('httpd/website.conf.erb'),
        notify  => Service['httpd'],
        require => Package['httpd'],
    }

    file { "/etc/httpd/conf.d/$name/logs.conf":
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        content => template('httpd/logs.conf.erb'),
        notify  => Service['httpd'],
        require => Package['httpd'],
    }

    file { "/etc/httpd/conf.d/$name/robots.conf":
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        content => template('httpd/robots.conf.erb'),
        notify  => Service['httpd'],
        require => Package['httpd'],
    }

    file { "/srv/web/robots.txt.$name":
        owner  => 'root',
        group  => 'root',
        mode   => '0644',
        source => [
          "puppet:///module/httpd/robots/robots.txt.$name",
          'puppet:///module/httpd/robots/robots.txt',
        ],
    }
}

