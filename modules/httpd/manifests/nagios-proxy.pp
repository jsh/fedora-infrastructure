define httpd::nagios-proxy($website) {
    file { "/etc/httpd/conf.d/$website/nagios.conf":
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        source  => 'puppet:///httpd/nagios.conf',
        notify  => Service['httpd'],
        require => Httpd::Website[$website],
    }
}

