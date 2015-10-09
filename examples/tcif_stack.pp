class profiles::tcif_stack {

  include ::profiles::ebrc_java_stack
  include ::profiles::ebrc_tomcat

  $global = hiera('tcif::global')

  tcif::global_config{ 'tcif':
    catalina_home => $global['catalina_home'],
    java_home     => $global['java_home'],
    instances_dir => $global['instances_dir'],
    oracle_home   => $global['oracle_home'],
    environment   => $global['environment'],
  }

  profiles::tomcat_instance{ 'TemplateDB': }

}