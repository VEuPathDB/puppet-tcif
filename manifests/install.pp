# install tomcat-instance-framework from RPM

class tcif::install {

  package { 'tomcat-instance-framework':
    ensure => installed,
  }
  
}