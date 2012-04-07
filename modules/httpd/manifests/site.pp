define httpd::site(
    $confsubdir = 'conf.d',
) {
    # cp $name.conf from websites path into apache config path
    # recurse $name subdir and copy into config path
    file { "/etc/httpd/$confsubdir/$name.conf":
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        source  => "puppet:///module/config/httpd/websites/$name.conf",
        notify  => Service['httpd'],
    }
    file { "/etc/httpd/$confsubdir/$name":
        ensure  => directory,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        source  => "puppet:///module/config/httpd/websites/$name",
        recurse => true,
        notify  => Service['httpd'],
    }
}
