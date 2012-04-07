define httpd::redirect(
    $website,
    $target,
    $path = '/',
    $status = 301,
) {
    file { "/etc/httpd/conf.d/$website/$name-redirect.conf":
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        content => template('httpd/redirect-proxy.conf.erb'),
        notify  => Service['httpd'],
        require => Httpd::Website[$website],
    }
}

