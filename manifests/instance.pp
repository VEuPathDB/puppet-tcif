# Manage an instance of the Tomcat Instance Framework .
# Requires puppetlabs/stdlib module for parameter validation.
#

define tcif::instance (
  $ensure            = running,
  $instance_name     = $name,
  $http_port         = undef,
  $ajp13_port        = undef,
  $jmx_port          = undef,
  $tomcat_user       = undef,
  $template_ver      = undef,
  $orcl_jdbc_path    = undef,
  $pg_jdbc_path      = undef,
  $instances_dir     = '/usr/local/tomcat_instances',
  $config_file       = undef,
  $environment       = undef,
  $addons            = undef,
  $public_logs       = false,
) {

  include ::tcif
  # https://github.com/puppet-community/puppet-archive , not yet in PuppetForge
  include 'archive'

  Exec    { require => Class['tcif'] }
  File    { require => Class['tcif'] }
  Service { require => Class['tcif'] }

  validate_bool($public_logs)

  $service_state = $ensure ? {
    'absent' => 'stopped',
    default  => $ensure
  }

  if ( $ensure == 'absent' ) {
    exec { "delete-active-${name}":
      command => "rm -rf ${instances_dir}/${name}",
      path    => '/usr/bin:/bin',
      onlyif  => "test -d ${instances_dir}/${name}",
      require => Service["tcif-${name}"],
    }
    exec { "delete-inactive-${name}":
      command => "rm -rf ${instances_dir}/_${name}",
      path    => '/usr/bin:/bin',
      onlyif  => "test -d ${instances_dir}/_${name}",
      require => Service["tcif-${name}"],
    }
  } else {

    if $instance_name == undef { fail("'instance_name' is not defined") }
    if $http_port == undef { fail("'http_port' is not defined") }
    if $ajp13_port == undef { fail("'ajp13_port' is not defined") }
    #if $jmx_port == undef { fail("'jmx_port' is not defined") }
    if $tomcat_user == undef { fail("'tomcat_user' is not defined") }
    if $template_ver == undef { fail("'template_ver' is not defined") }

    if $orcl_jdbc_path {
      validate_absolute_path($orcl_jdbc_path)
    }

    if $pg_jdbc_path {
      validate_absolute_path($pg_jdbc_path)
    }

    if $instances_dir {
      validate_absolute_path($instances_dir)
    }

    $make_cmd = "make install                     \
      INSTANCE=${instance_name}                   \
      HTTP_PORT=${http_port}                      \
      AJP13_PORT=${ajp13_port}                    \
      JMX_PORT=${jmx_port}                        \
      TOMCAT_USER=${tomcat_user}                  \
      TEMPLATE=${template_ver}
    "
    exec { "make-${instance_name}":
      command => $make_cmd,
      path    => ['/usr/local/bin', '/bin', '/usr/bin'],
      cwd     => $instances_dir,
      unless  => "test -d ${instances_dir}/_${name}",
      creates => "${instances_dir}/${instance_name}",
    }

    if ( $ensure == 'running' ) {
      file { "${name}-env":
        path    => "${instances_dir}/${name}/conf/instance.env",
        owner   => $tomcat_user,
        group   => 'tomcat',
        mode    => '0644',
        content => template('tcif/instance.env.erb'),
        require => [Exec["make-${instance_name}"]],
        notify  => Service["tcif-${name}"]
      }
    }

    if ( $ensure == 'stopped' ) {
      exec { "disable-${name}":
        path    => '/usr/bin:/bin',
        command => "mv ${instances_dir}/${name} ${instances_dir}/_${name}",
        creates => "${instances_dir}/_${name}",
        require => [Exec["make-${instance_name}"], Service["tcif-${name}"]],
      }

      if ($public_logs == true) {
        file { "${instances_dir}/_${name}/logs":
          mode    => '0644',
          recurse => true,
          require => Exec["make-${instance_name}"]
        }
      } else {
        file { "${instances_dir}/_${name}/logs":
          mode    => '0640',
          recurse => true,
          require => Exec["make-${instance_name}"]
        }
      } # if ($public_logs == true)

    }

    if ( $ensure == 'running' ) {
      exec { "enable-${name}":
        command => "mv ${instances_dir}/_${name} ${instances_dir}/${name}",
        path    => '/usr/bin:/bin',
        onlyif  => "test -d ${instances_dir}/_${name}",
        creates => "${instances_dir}/${name}",
        notify  => Service["tcif-${name}"],
        before  => Exec["make-${instance_name}"],
      }

      if ($public_logs == true) {
        file { "${instances_dir}/${name}/logs":
          mode    => '0644',
          recurse => true,
          require => Exec["make-${instance_name}"]
        }
      } else {
        file { "${instances_dir}/${name}/logs":
          mode    => '0640',
          recurse => true,
          require => Exec["make-${instance_name}"]
        }
      } # if ($public_logs == true)

    } # if ( $ensure == 'running' )

    if $addons {

      $addon_rekeyed = tcif_rekey_hash($addons, "${name}_")

      $defaults = {
        instance_name => $name,
        instances_dir => $instances_dir,
      }
      create_resources('tcif::instance_addons', $addon_rekeyed, $defaults)
    }

  } # $ensure != 'absent'

  service { "tcif-${name}":
    provider => init,
    ensure   => $service_state,
    start    => "instance_manager start ${name}",
    stop     => "instance_manager stop ${name} force",
    restart  => "instance_manager restart ${name}",
    status   => "instance_manager status ${name}",
  }

}
