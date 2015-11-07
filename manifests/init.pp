# Install Tomcat Instance Framework and manage its service
class tcif (
  $tomcat_group = $::tcif::params::tomcat_group,
) inherits ::tcif::params {

  contain tcif::install
  contain tcif::service

  Class['::tcif::install'] ->
  Class['::tcif::service']

}
