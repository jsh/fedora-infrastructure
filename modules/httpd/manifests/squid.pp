class httpd::squid inherits httpd::base {
    File['/etc/httpd/conf/httpd.conf'] {
        source => 'puppet:///httpd/httpd.conf-squidaccel',
    }
}

