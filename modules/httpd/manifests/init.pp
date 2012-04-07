class httpd::base {
    include logrotate

    package { "httpd":
        ensure => installed,
    }

    service { "httpd":
        enable    => true,
        ensure    => running,
        hasstatus => true,
        restart   => "/sbin/service httpd graceful",
        require   => Package["httpd"],
    }

    if $operatingsystemrelease >= 6 {
        semanage_fcontext { '/srv/web(/.*)?':
            type => 'httpd_sys_content_t'
        }
    }

    file { "/etc/httpd/conf/httpd.conf":
        owner   => "root",
        group   => "root",
        mode    => 0644,
        source => "puppet:///httpd/httpd.conf",
        notify  => Service["httpd"],
        require => Package["httpd"],
    }

    file { "/srv/web":
        owner  => "root",
        group  => "root",
        mode   => 0755,
        ensure => directory,
    }

    # This is disabled on releng2 and relepel1 as bodhi runs
    # mash in a thread which gets killed on an httpd reload
    file { "/etc/logrotate.d/httpd":
        owner   => "root",
        group   => "root",
        mode    => 0644,
        source  => "puppet:///httpd/httpd.logrotate",
        require => Package["httpd"],
        ensure  => $hostname ? {
            releng2  => absent,
            relepel1 => absent,
            default  => file,
        }
    }
}

class httpd::mod_ssl inherits httpd::base {
    package { "mod_ssl":
        ensure => installed,
    }

    file { "/etc/httpd/conf.d/ssl.conf":
        owner   => "root",
        group   => "root",
        mode    => 0644,
        notify  => Service["httpd"],
        require => Package["httpd"],
        source  => "puppet:///httpd/ssl.conf",
    }
}

class httpd::mod_auth_pgsql inherits httpd::base {
    package { "mod_auth_pgsql":
        ensure => installed,
    }
}

class httpd::mod_wsgi inherits httpd::base {
    package { "mod_wsgi":
        ensure => installed,
    }

    file { "/etc/httpd/conf.d/wsgi.conf":
        owner   => "root",
        group   => "root",
        mode    => 0644,
        notify  => Service["httpd"],
        require => Package["httpd"],
        source  => "puppet:///httpd/wsgi.conf",
    }
}

class httpd::mod_cache inherits httpd::base {

    file { "/srv/cache":
        owner   => "apache",
        group   => "root",
        mode    => 0750,
        ensure  => directory,
        require => Package["httpd"],
    }

    file { "/srv/cache/mod_cache":
        owner   => "apache",
        group   => "root",
        mode    => 0750,
        ensure  => directory,
        require => Package["httpd"],
    }

    cron { "clean-httpd-cache":
        command => "/usr/sbin/htcacheclean -p /srv/cache/mod_cache/ -l 200M | logger -p local0.notice -t httpd",
        user    => "apache",
        hour    => [ 2, 8, 14, 20 ],
        minute  => [ 15 ],
    }
}

class httpd::proxy inherits httpd::base {
    File["/etc/httpd/conf/httpd.conf"] {
        source => "puppet:///httpd/httpd.conf-rhel5p",
    }

    file { "/etc/httpd/conf.d/00-namevirtualhost.conf":
        owner   => "root",
        group   => "root",
        mode    => 0644,
        source  => "puppet:///httpd/00-namevirtualhost.conf",
        notify  => Service["httpd"],
        require => Package["httpd"],
    }

    file { "/etc/httpd/conf.d/01-keepalives.conf":
        owner   => "root",
        group   => "root",
        mode    => 0644,
        source  => "puppet:///httpd/01-keepalives.conf",
        notify  => Service["httpd"],
        require => Package["httpd"],
    }

    file { "/etc/httpd/conf.d/welcome.conf":
        ensure  => absent,
        notify  => Service["httpd"],
        require => Package["httpd"],
    }

    file { "/etc/httpd/conf.d/headers.conf":
        owner   => "root",
        group   => "root",
        mode    => 0644,
        content => template("httpd/proxy-headers.conf.erb"),
        notify  => Service["httpd"],
        require => Package["httpd"],
    }
}

class httpd::app inherits httpd::base {
    File["/etc/httpd/conf/httpd.conf"] {
        source => "puppet:///httpd/httpd.conf-rhel5app",
    }

    file { "/etc/httpd/conf.d/headers.conf":
        owner   => "root",
        group   => "root",
        mode    => 0644,
        content => template("httpd/app-headers.conf.erb"),
        notify  => Service["httpd"],
        require => Package["httpd"],
    }
}

class httpd::fasserver inherits httpd::base {
    File["/etc/httpd/conf/httpd.conf"] {
        source => "puppet:///httpd/httpd.conf.fas",
    }

    file { "/etc/httpd/conf.d/headers.conf":
        owner   => "root",
        group   => "root",
        mode    => 0644,
        content => template("httpd/app-headers.conf.erb"),
        notify  => Service["httpd"],
        require => Package["httpd"],
    }
}

class httpd::koji inherits httpd::base {
    File["/etc/httpd/conf/httpd.conf"] {
        source => "puppet:///httpd/httpd.conf-koji",
    }

    file { "/etc/httpd/conf.d/headers.conf":
        owner   => "root",
        group   => "root",
        mode    => 0644,
        content => template("httpd/koji-headers.conf.erb"),
        notify  => Service["httpd"],
        require => Package["httpd"],
    }
}

class httpd::squid inherits httpd::base {
    File["/etc/httpd/conf/httpd.conf"] {
        source => "puppet:///httpd/httpd.conf-squidaccel",
    }
}

class httpd::retrace inherits httpd::proxy {
    File["/etc/httpd/conf/httpd.conf"] {
        source => "puppet:///httpd/httpd.conf-retrace",
    }
}

define httpd::certificate(
    $cert = "",
    $key = "",
    $sSLCertificateChainFile = ""
) {
    include httpd::mod_ssl

    $cert_source = $cert ? {
        ""      => "puppet:///config/secure/httpd/$name.cert",
        default => $cert,
    }

    $key_source = $key ? {
        ""      => "puppet:///config/secure/httpd/$name.key",
        default => $key,
    }

    if $sSLCertificateChainFile != "" {
        file { "/etc/pki/tls/certs/$sSLCertificateChainFile":
            owner => "root",
            group => "root",
            mode => "0644",
            source => "puppet:///config/secure/httpd/$sSLCertificateChainFile",
            notify => Service["httpd"],
            require => Package["httpd"],
        }
    }

    file { "/etc/pki/tls/certs/$name.cert":
        owner   => "root",
        group   => "root",
        mode    => 0644,
        source  => $cert_source,
        notify  => Service["httpd"],
        require => Package["httpd"],
    }

    file { "/etc/pki/tls/private/$name.key":
        owner   => "root",
        group   => "root",
        mode    => 0600,
        source  => $key_source,
        notify  => Service["httpd"],
        require => Package["httpd"],
    }
}

define httpd::website(
    $ips = [],
    $server_aliases = [],
    $server_admin = "webmaster@fedoraproject.org",
    $ssl = false,
    $sslonly = false,
    $cert_name  = "",
    $sSLCertificateChainFile = ""
) {
    file { "/etc/httpd/conf.d/$name":
        owner   => "root",
        group   => "root",
        mode    => 0755,
        ensure  => directory,
        require => $ssl ? {
            false   => Package["httpd"],
            default => [
                Package["httpd"],
                Httpd::Certificate[$cert_name],
            ],
        },
    }

    file { "/etc/httpd/conf.d/$name.conf":
        owner   => "root",
        group   => "root",
        mode    => 0644,
        content => template("httpd/website.conf.erb"),
        notify  => Service["httpd"],
        require => Package["httpd"],
    }

    file { "/etc/httpd/conf.d/$name/logs.conf":
        owner   => "root",
        group   => "root",
        mode    => 0644,
        content => template("httpd/logs.conf.erb"),
        notify  => Service["httpd"],
        require => Package["httpd"],
    }

    file { "/etc/httpd/conf.d/$name/robots.conf":
        owner   => "root",
        group   => "root",
        mode    => 0644,
        content => template("httpd/robots.conf.erb"),
        notify  => Service["httpd"],
        require => Package["httpd"],
    }

    file { "/srv/web/robots.txt.$name":
        owner  => "root",
        group  => "root",
        mode   => 0644,
        source => [
           "puppet:///httpd/robots/robots.txt.$name",
           "puppet:///httpd/robots/robots.txt",
        ],
    }
}

define httpd::redirect(
    $website,
    $path = "/",
    $target,
    $status = 301
) {
    file { "/etc/httpd/conf.d/$website/$name-redirect.conf":
        owner   => "root",
        group   => "root",
        mode    => 0644,
        content => template("httpd/redirect-proxy.conf.erb"),
        notify  => Service["httpd"],
        require => Httpd::Website[$website],
    }
}

define httpd::status(
    $website,
    $path = "/"
) {
    file { "/etc/httpd/conf.d/$website/apache-status.conf":
        owner   => "root",
        group   => "root",
        mode    => 0644,
        content => template("httpd/apache-status.conf.erb"),
        notify  => Service["httpd"],
        require => Httpd::Website[$website],
    }
}

define httpd::domainrewrite(
    $website,
    $path = '^/$',
    $target,
    $status = 302,
    $ensure = present
) {
    file { "/etc/httpd/conf.d/$website/$name-rewrite.conf":
        owner   => "root",
        group   => "root",
        mode    => 0644,
        content => template("httpd/rewrite-proxy.conf.erb"),
        notify  => Service["httpd"],
        require => Httpd::Website[$website],
        ensure  => $ensure,
    }
}

define httpd::domainnotarget(
    $website,
    $path,
    $status = 410,
    $ensure = present
) {
    file { "/etc/httpd/conf.d/$website/$name-rewrite.conf":
        owner   => "root",
        group   => "root",
        mode    => 0644,
        content => template("httpd/rewrite-notarget.conf.erb"),
        notify  => Service["httpd"],
        require => Httpd::Website[$website],
        ensure  => $ensure,
    }
}

class httpd::php { #inherits httpd::base {
    package { "php":
        ensure => installed,
    }

    package { "php-pecl-apc":
        ensure => installed,
    }

    file { "/etc/php.ini":
        content => template("httpd/php/php.ini.erb"),
        notify  => Service["httpd"],
        require => Package["php"],
    }

    file { "/etc/php.d/apc.ini":
        source  => "puppet:///httpd/php/apc.ini",
        notify  => Service["httpd"],
        require => Package["php"],
    }

    file { "/srv/web/sessiondata":
        owner   => "apache",
        group   => "apache",
        ensure  => directory,
        require => Package["httpd"],
    }
}

class httpd::php-pecl-json {
    package { "php-pecl-json":
        ensure => installed,
    }

    file { "/etc/php.d/json.ini":
        source  => "puppet:///httpd/php/json.ini",
        notify  => Service["httpd"],
        require => Package["php"],
    }
}

# This is a temporary class to get the nagios interface working
# while we move over to Zabbix.
define httpd::nagios-proxy($website) {
    file { "/etc/httpd/conf.d/$website/nagios.conf":
        owner   => "root",
        group   => "root",
        mode    => 0644,
        source  => "puppet:///httpd/nagios.conf",
        notify  => Service["httpd"],
        require => Httpd::Website[$website],
    }
}

define httpd::mailman-proxy(
    $website,
    $path,
    $iconpath,
    $proxyurl
) {
    file { "/etc/httpd/conf.d/$website/mailman.conf":
        owner   => "root",
        group   => "root",
        mode    => 0644,
        content => template("httpd/mailman-proxy.conf.erb"),
        notify  => Service["httpd"],
        require => Httpd::Website[$website],
    }
}

define httpd::mime-type(
    $website,
    $mimetype,
    $extensions
) {
    file { "/etc/httpd/conf.d/$website/mime-types.conf":
        owner   => "root",
        group   => "root",
        mode    => 0644,
        content => template("httpd/mime-types.conf.erb"),
        notify  => Service["httpd"],
        require => Httpd::Website[$website],
    }
}



class  httpd::newbase {

    package { "httpd":
        ensure => installed,
    }

    service { "httpd":
        enable    => true,
        ensure    => running,
        hasstatus => true,
        restart   => "/sbin/service httpd graceful",
        require   => Package["httpd"],
    }

    if $operatingsystemrelease >= 6 {
        semanage_fcontext { '/srv/web(/.*)?':
            type => 'httpd_sys_content_t'
        }
    }

    file { "/etc/httpd/conf/httpd.conf":
        owner   => "root",
        group   => "root",
        mode    => 0644,
        source  => "puppet:///httpd/httpd.conf.$distrorelease",
        notify  => Service["httpd"],
        require => Package["httpd"],
    }

    file { "/srv/web":
        owner  => "root",
        group  => "root",
        mode   => 0755,
        ensure => directory,
    }

    file { "/srv/web/robots.txt.lockbox01":
        owner  => "root",
        group  => "root",
        mode   => 0644,
        source => "puppet:///httpd/robots/robots.txt.lockbox01",
    }
}

define httpd::site(
    $confsubdir = 'conf.d'
) {
    # cp $name.conf from websites path into apache config path
    # recurse $name subdir and copy into config path
    file { "/etc/httpd/$confsubdir/$name.conf":
        owner   => "root",
        group   => "root",
        mode    => 0644,
        source  => "puppet:///config/httpd/websites/$name.conf",
        notify  => Service["httpd"],
    }
    file { "/etc/httpd/$confsubdir/$name":
        owner   => "root",
        group   => "root",
        mode    => 0644,
        source  => "puppet:///config/httpd/websites/$name",
        recurse => true,
        ensure  => directory,
        notify  => Service["httpd"],
    }
}
