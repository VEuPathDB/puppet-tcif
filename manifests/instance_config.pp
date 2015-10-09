# Manage the instance.env configuration file for the named instance.

define tcif::instance_config (
  $catalina_home = undef,
  $java_home = undef,
  $instances_dir = '/usr/local/tomcat_instances',
  $oracle_home = undef,
  $environment = undef,
  $auto_deploy = false,
) {

  # stdlib validate_absolute_path() only checks if string
  # looks like it could be a path, not if the path exists.
  validate_absolute_path($instances_dir)
  validate_bool($auto_deploy)

  file { "${instances_dir}/${name}/conf/instance.env":
    content => template('tcif/instance.env.erb'),
    require => Package['tomcat-instance-framework'],
  }

}
