class tcif::modjk_connector {

  $instances_data = lookup('tcif::instances', Hash)

  contain '::apache_ext::mod::jk'

  file { '/etc/httpd/conf/workers.properties':
    content => template('tcif/workers.properties.erb'),
    require => Class['::apache_ext::mod::jk'],
  }

}