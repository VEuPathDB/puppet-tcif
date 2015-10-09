# manage tomcat service

class tcif::service {

  service { 'tomcat':
    ensure  => running,
    enable  => true,
    require => Package['tomcat-instance-framework'],
  }

}