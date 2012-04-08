define httpd::status(
    $website,
    $path = '/',
) {
    file { "/etc/httpd/conf.d/$website/apache-status.conf":
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        content => template('httpd/apache-status.conf.erb'),
        notify  => Service['httpd'],
        require => Httpd::Website[$website],
    }
}

