define httpd::mailman-proxy(
    $website,
    $path,
    $iconpath,
    $proxyurl
) {
    file { "/etc/httpd/conf.d/$website/mailman.conf":
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        content => template('httpd/mailman-proxy.conf.erb'),
        notify  => Service['httpd'],
        require => Httpd::Website[$website],
    }
}

