define httpd::domainnotarget(
    $website,
    $path,
    $ensure = present,
    $status = 410,
) {
    file { "/etc/httpd/conf.d/$website/$name-rewrite.conf":
        ensure  => $ensure,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        content => template('httpd/rewrite-notarget.conf.erb'),
        notify  => Service['httpd'],
        require => Httpd::Website[$website],
    }
}

