Install [EupathDB's Tomcat Instance Framework](https://github.com/EuPathDB/tomcat-instance-framework)

## Requirements

#### Puppet Modules

- [PuppetLabs stdlib module](https://forge.puppetlabs.com/puppetlabs/stdlib)
- [Puppet-Community archive module](https://forge.puppetlabs.com/puppet/archive)

#### Node dependencies

The node must have the following installed and configured before this module can be used. You are responsible for arranging dependency resolutions. See `tcif_stack.pp` in the `examples` directory for a sample profile manifest.
 
- A YUM repo that provides the Tomcat Instance Framework rpm.
- Tomcat
- Java

## Install Tomcat Instance Framework

    include tcif

This installs the `tcif` RPM from a YUM repository.

## Global TcIF Configuration

The configuration file `shared/conf/global.env` which profides default configurations to all instances can be managed with the `tcif::global_config` definition.

    tcif::global_config{ 'tcif':
      catalina_home => '/usr/local/apache-tomcat-6.0.35',
      java_home     => '/usr/java/jdk1.7.0_25',
      instances_dir => '/usr/local/tomcat_instances,
      oracle_home   => '/u01/app/oracle/product/11.2.0.3/db_1',
      environment   => 'CATALINA_OPTS["MEM"]="-Xms256m -Xmx1024m"',
    }

#### catalina_home

#### java_home

#### instances_dir

#### oracle_home

#### environment
optional. Additional entries in the `instance.env` file. Only used with `instance.env.erb` or other template.

## Create a named instance

    tcif::instance { 'TemplateDB':
      ensure         => running,
      http_port      => 8080,
      ajp13_port     => 8081,
      jmx_port       => 8082,
      tomcat_user    => tomcat,
      template_ver   => 6.0.35,
      orcl_jdbc_path => $orcl_jdbc_path,
      pg_jdbc_path   => /usr/share/java/postgresql94-jdbc.jar,
      environment    => $environment,
      config_file    => template('tcif/instance.env.erb'),
      require        => Class['tcif'],
    }

See `tomcat_instance.pp` in the `example` directory for a sample define that uses hiera data.

## Parameters for `tcif::instance`

#### ensure

valid values are

  - `running` - The instance exists and has a running `jsvc` process. This is the default. If the instance does not exist it will be created and started. If the instance exists in a `stopped` state it will started.
  - `absent` - The instance directory does not exist. It will be shutdown and deleted if necessary.
  - `stopped` - The instance exists but has not running `jsvc` process. The instance directory is renamed with a leading underscore (`_`) so it will be ignored by `instance_manager` and will not be managed with the `tomcat` service. A disabled instance will not receive configuration updates. If the instance is not present on the system it will be created and then set to the `stopped` state.


#### http\_port     

#### ajp13\_port    

#### jmx\_port      

#### tomcat\_user   

#### template\_ver

A template version matching a directory name in
`/usr/local/tomcat_instances/templates`. This template is used to `make`
the instance and includes configurations specific to a given version of
Tomcat. Changing the `template_ver` after the instance has been made
will have no affect.

#### addons
optional. Files to install into the instance. The instance will be restarted upon 
changes to addons. The value for addons is a hash

    $addons = {
      Jolokia => {
        source => 'https://repo1.maven.org/maven2/org/jolokia/jolokia-war/1.3.2/jolokia-war-1.3.2.war'
        sha256 => '845f3e0de2c2595ef8051941aa00139e618df6f3a921ad8485775678939b572d'
        dest   => 'webapps/jolokia.war'
      }
      JDBC => {
        source => "file:///u01/app/oracle/product/11.2.0.3/db_1/jdbc/lib/ojdbc6.jar"
        dest:  => 'shared/lib/ojdbc6.jar'
      }
    }

The parameters are:

  - source: Required. The location of the file being installed. This uses the archive module so its syntax requirements apply.
  - dest: Required. The relative filepath destination, including file name. This path is relative to `${instances_dir}/${instance_name}`.
  - sha256: Optional. The sha256 checksum of the source file. See documentation for the archive module for details. If not defined, no checksum validation will occur.

#### environment
optional. Additional entries in the `instance.env` file (provided the
`instance.env` file originates from the `instance.env.erb` template).

    PlasmoDB:
      ensure:       stopped
      http_port:    9480
      ajp13_port:   9409
      jmx_port:     9405
      tomcat_user:  tomcat_4
      template_ver: 6.0.35
      environment: |
        CATALINA_OPTS['MEM']="   \
            -Xms1024m -Xmx2048m \
            -XX:MaxPermSize=1024m"
        %{lookup('tcif::instances::default_environment')}

The `environment` will override `tcif::instances::default_environment`,
so be sure to include the `tcif::instances::default_environment` value
from hiera, as shown in the example, if you want to keep the defaults.

#### config\_file
The origin of the `instance.env` file.

#### public\_logs
`true` or `false` whether the tomcat instance logs are world readable. Default `false`.


