# Manage an instance of the Tomcat Instance Framework .
# Requires puppetlabs/stdlib module for parameter validation.
#

define tcif::instance (
  $ensure                                        = running,
  $instance_name                                 = $name,
  Integer $http_port,
  Integer $ajp13_port,
  String  $ajp13_secret,
  String  $ajp13_allowedRequestAttributesPattern,
  Optional[Integer] $jmx_port                    = undef,
  Optional[Integer] $jprofiler_port              = undef,
  String $tomcat_user,
  $tomcat_group                                  = $::tcif::tomcat_group,
  String $template_ver,
  Optional[Stdlib::AbsolutePath] $orcl_jdbc_path = undef,
  Optional[Stdlib::AbsolutePath] $pg_jdbc_path   = undef,
  Stdlib::AbsolutePath $instances_dir            = '/usr/local/tomcat_instances',
  $config_file                                   = undef,
  $environment                                   = undef,
  $addons                                        = undef,
  Boolean $public_logs                           = false,
) {

  include ::tcif
  include 'archive'

  Exec    { require => Class['tcif'] }
  File    { require => Class['tcif'] }
  Service { require => Class['tcif'] }

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

    # Set correct context for the logs directory otherwise logrotate can't access the logs.
    selinux::fcontext{ "set ${instances_dir}/${instance_name}/logs(/.*)? context":
      seltype  => 'tomcat_log_t',
      pathspec => "${instances_dir}/${instance_name}/logs(/.*)?",
      require => [Exec["make-${instance_name}"]],
    }

    if ( $ensure == 'running' ) {
      file { "${name}-env":
        path    => "${instances_dir}/${name}/conf/instance.env",
        owner   => $tomcat_user,
        group   => $tomcat_group,
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

      file { "${name}-env":
        path    => "${instances_dir}/_${name}/conf/instance.env",
        owner   => $tomcat_user,
        group   => $tomcat_group,
        mode    => '0644',
        content => template('tcif/instance.env.erb'),
        require => Exec["disable-${name}"],
      }

      if ($public_logs == true) {
        file { "${instances_dir}/_${name}/logs":
          mode    => '0644',
          owner   => $tomcat_user,
          group   => $tomcat_group,
          recurse => false,
          require => Exec["disable-${name}"],
        }
      } else {
        file { "${instances_dir}/_${name}/logs":
          mode    => '0640',
          owner   => $tomcat_user,
          group   => $tomcat_group,
          recurse => false,
          require => Exec["disable-${name}"],
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
          owner   => $tomcat_user,
          group   => $tomcat_group,
          recurse => false,
          require => Exec["make-${instance_name}"]
        }
      } else {
        file { "${instances_dir}/${name}/logs":
          mode    => '0640',
          owner   => $tomcat_user,
          group   => $tomcat_group,
          recurse => false,
          require => Exec["make-${instance_name}"]
        }
      } # if ($public_logs == true)

    } # if ( $ensure == 'running' )

    if $addons {

      $addon_rekeyed = tcif_rekey_hash($addons, "${name}_")

      $defaults = {
        instance_name   => $name,
        instances_dir   => $instances_dir,
        instance_ensure => $ensure
      }
      create_resources('tcif::instance_addons', $addon_rekeyed, $defaults)
    }

  } # $ensure != 'absent'

  service { "tcif-${name}":
    ensure   => $service_state,
    start    => "instance_manager start ${name}",
    stop     => "instance_manager stop ${name} force",
    restart  => "instance_manager restart ${name}",
    status   => "instance_manager status ${name}",
    provider => "base",
  }

}
