class httpd::mod_auth_pgsql inherits httpd::base {
    package { 'mod_auth_pgsql':
        ensure => installed,
    }
}

