module Puppet::Parser::Functions
  newfunction(:tcif_picker, :type => :rvalue, :doc => <<-EOS) do |args|
    Pick a subset of TcIF data by hash key values.
    For example, to select FooDB and BarDB from tcif::instances 
    hiera data, do

      $instances_data = hiera('tcif::instances')
      tcif_picker(['FooDB', 'BarDB'], $instances_data)

    EOS

    if args.length < 2
      raise Puppet::ParseError, ("generate_resource_hash(): wrong number of args (#{args.length}; must be at least 2)")
    end

    wanted_keys = args[0]
    tcif_instances_hash = args[1]
    selected_instances = tcif_instances_hash.select { |key,val| wanted_keys.include? key }
    selected_instances
  end
end
