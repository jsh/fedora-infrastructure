define httpd::mime-type(
    $website,
    $mimetype,
    $extensions
) {
    file { "/etc/httpd/conf.d/$website/mime-types.conf":
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        content => template('httpd/mime-types.conf.erb'),
        notify  => Service['httpd'],
        require => Httpd::Website[$website],
    }
}



