#
define tcif::global_config (
  Stdlib::AbsolutePath $catalina_home = undef,
  Stdlib::AbsolutePath $java_home = undef,
  Stdlib::AbsolutePath $instances_dir = '/usr/local/tomcat_instances',
  Optional[Stdlib::AbsolutePath] $oracle_home = undef,
  String $environment = undef,
  Boolean $auto_deploy = false,
) {

  include tcif

  file { "${instances_dir}/shared/conf/global.env":
    owner   => 'tomcat',
    group   => 'tomcat',
    content => template('tcif/global.env.erb'),
    require => Package['tomcat-instance-framework'],
    notify  => Service['tomcat'],
  }

}
