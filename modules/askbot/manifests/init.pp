class askbot {
    include httpd::mod_wsgi

    package { "askbot":
        ensure => installed,
    }
    # Should this be part of the rpm package?  Probably optional so no
    package { "python-memcached":
        ensure => present
    }

    # Apache
    file { "/etc/httpd/conf.d/askbot.conf":
        owner   => "root",
        group   => "root",
        mode    => 0644,
        source  => "puppet:///askbot/askbot.conf",
        notify  => Service["httpd"],
        require => Package["httpd"],
    }

    # Contains db passwords
    file { "/etc/askbot/sites/ask/config/settings.py":
        owner   => "apache",
        group   => "apache",
        mode    => 0600,
	content => template("askbot/settings.erb"),
    }
}

define askbot::proxy(
    $website,
    $path,
    $proxyurl
) {
    include httpd::base

    file { "/etc/httpd/conf.d/$website/askbot.conf":
        owner   => "root",
        group   => "root",
        mode    => 0644,
        content => template("askbot/askbot-proxy.conf.erb"),
        notify  => Service["httpd"],
        require => Httpd::Website[$website],
    }
}
