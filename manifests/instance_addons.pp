# Install 'addons' into a named instance.
# Parameters:
#   $instance_name: Required. The name of the instance being amended
#   $instances_dir: Required. The base directory path where $instance_name
#                    is located.
#   $source: Required. The location of the file being installed. This uses
#            the archive module so its syntax requirements apply. See
#            https://github.com/puppet-community/puppet-archive
#   $dest: Required. The relative filepath destination, including file name.
#          This path is relative to the ${instances_dir}/${instance_name}.
#   $sha256: Optional. The sha256 checksum of the source file. See documentation
#            for the archive module for details. If not defined, no checksum
#            validation will occur.
#
# The instance will be restarted upon changes to addons.
#
# TODO: if $source value begins with 'puppet://' then use File resource
# instead of the archive module.
#
define tcif::instance_addons (
  $ensure = 'present',
  $instance_name = undef,
  $instances_dir = undef,
  $source = undef,
  $dest = undef,
  $sha256 = undef,
) {

  if $ensure == 'absent' {
    file { "${instances_dir}/${instance_name}/${dest}":
      ensure => absent,
      notify => Service["tcif-${instance_name}"],
    }
  } else {

    if $sha256 {
      $checksum = $sha256
      $checksum_type = 'sha256'
    } else {
      $checksum = undef
      $checksum_type = undef
    }

    archive { "${instances_dir}/${instance_name}/${dest}":
      ensure        => present,
      extract       => false,
      source        => $source,
      checksum      => $checksum,
      checksum_type => $checksum_type,
      notify        => Service["tcif-${instance_name}"],
    }

  }
}
