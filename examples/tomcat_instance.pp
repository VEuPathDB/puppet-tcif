# manage named tomcat instance using the Tomcat Instance Framework

define profiles::tomcat_instance() {

  include tcif

  $instances_data = hiera('tcif::instances')

  $ensure         = $instances_data[$name]['ensure']
  $http_port      = $instances_data[$name]['http_port']
  $ajp13_port     = $instances_data[$name]['ajp13_port']
  $jmx_port       = $instances_data[$name]['jmx_port']
  $tomcat_user    = $instances_data[$name]['tomcat_user']
  $template_ver   = $instances_data[$name]['template_ver']
  $orcl_jdbc_path = $instances_data[$name]['orcl_jdbc_path']
  $pg_jdbc_path   = $instances_data[$name]['pg_jdbc_path']
  $world_readable = $instances_data[$name]['world_readable']
  $environment    = $instances_data[$name]['environment']

  tcif::instance { $name:
    ensure         => $ensure,
    http_port      => $http_port,
    ajp13_port     => $ajp13_port,
    jmx_port       => $jmx_port,
    tomcat_user    => $tomcat_user,
    template_ver   => $template_ver,
    environment    => $environment,
    config_file    => template('tcif/instance.env.erb'),
    require        => Class['tcif'],
  }

}
