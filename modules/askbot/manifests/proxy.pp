define askbot::proxy(
  $website,
  $path,
  $proxyurl,
) {
  include httpd::base

  file { "/etc/httpd/conf.d/$website/askbot.conf":
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('askbot/askbot-proxy.conf.erb'),
    notify  => Service['httpd'],
    require => Httpd::Website[$website],
  }
}
