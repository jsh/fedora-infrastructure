class httpd::retrace inherits httpd::proxy {
    File['/etc/httpd/conf/httpd.conf'] {
        source => 'puppet:///module/httpd/httpd.conf-retrace',
    }
}

