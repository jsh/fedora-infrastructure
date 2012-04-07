define httpd::certificate(
    $cert = '',
    $key = '',
    $sSLCertificateChainFile = '',
) {
    include httpd::mod_ssl

    $cert_source = $cert ? {
        "'      => 'puppet:///module/config/secure/httpd/$name.cert",
        default => $cert,
    }

    $key_source = $key ? {
        "'      => 'puppet:///module/config/secure/httpd/$name.key",
        default => $key,
    }

    if $sSLCertificateChainFile != '' {
        file { "/etc/pki/tls/certs/$sSLCertificateChainFile":
            owner   => 'root',
            group   => 'root',
            mode    => '0644',
            source  => "puppet:///module/config/secure/httpd/$sSLCertificateChainFile",
            notify  => Service['httpd'],
            require => Package['httpd'],
        }
    }

    file { "/etc/pki/tls/certs/$name.cert":
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        source  => $cert_source,
        notify  => Service['httpd'],
        require => Package['httpd'],
    }

    file { "/etc/pki/tls/private/$name.key":
        owner   => 'root',
        group   => 'root',
        mode    => '0600',
        source  => $key_source,
        notify  => Service['httpd'],
        require => Package['httpd'],
    }
}

