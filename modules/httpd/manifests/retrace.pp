class httpd::retrace inherits httpd::proxy {
    File['/etc/httpd/conf/httpd.conf'] {
        source => 'puppet:///httpd/httpd.conf-retrace',
    }
}

