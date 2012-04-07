define httpd::domainrewrite(
    $website,
    $target,
    $path = '^/$',
    $status = 302,
    $ensure = present,
) {
    file { "/etc/httpd/conf.d/$website/$name-rewrite.conf":
        ensure  => $ensure,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        content => template('httpd/rewrite-proxy.conf.erb'),
        notify  => Service['httpd'],
        require => Httpd::Website[$website],
    }
}

