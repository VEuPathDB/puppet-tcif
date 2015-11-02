class tcif::modjk_connector {

  $instances_data = hiera_hash('tcif::instances')

  package { 'mod_jk':
    ensure => present,
  }

  file { '/etc/httpd/conf/workers.properties':
    content => template('tcif/workers.properties.erb'),
    require => Package['mod_jk'],
  }

}