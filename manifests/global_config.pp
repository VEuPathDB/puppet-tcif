#
define tcif::global_config (
  $catalina_home = undef,
  $java_home = undef,
  $instances_dir = '/usr/local/tomcat_instances',
  $oracle_home = undef,
  $environment = undef,
  $auto_deploy = false,
) {

  include tcif

  # stdlib validate_absolute_path() only checks if string
  # looks like it could be a path, not if the path exists.
  validate_absolute_path($catalina_home)
  validate_absolute_path($instances_dir)
  validate_bool($auto_deploy)

  file { "${instances_dir}/shared/conf/global.env":
    owner   => 'tomcat',
    group   => 'tomcat',
    content => template('tcif/global.env.erb'),
    require => Package['tomcat-instance-framework'],
    notify  => Service['tomcat'],
  }

}
