# Install Tomcat Instance Framework and manage its service

class tcif {

  contain tcif::install
  contain tcif::service

  Class['::tcif::install'] ->
  Class['::tcif::service']

}
