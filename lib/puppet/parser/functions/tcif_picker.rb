module Puppet::Parser::Functions
  newfunction(:tcif_picker, :type => :rvalue, :doc => <<-EOS) do |args|
    Prefixes each hash key with the given string.
    For example, to prefix each key with the resource name, use
      tcif_picker($hash, $name)
    This is useful to avoid 'duplicate declaration' errors when
    passing a sub-hash to a create_resource().
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
