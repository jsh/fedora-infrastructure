class httpd::squid inherits httpd::base {
    File['/etc/httpd/conf/httpd.conf'] {
        source => 'puppet:///module/httpd/httpd.conf-squidaccel',
    }
}

