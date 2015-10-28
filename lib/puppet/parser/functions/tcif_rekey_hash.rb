module Puppet::Parser::Functions
  newfunction(:tcif_rekey_hash, :type => :rvalue, :doc => <<-EOS) do |args|
    Prefixes each hash key with the given string.
    For example, to prefix each key with the resource name, use
      tcif_rekey_hash($hash, $name)
    This is useful to avoid 'duplicate declaration' errors when
    passing a sub-hash to a create_resource().
    EOS

    if args.length < 2
      raise Puppet::ParseError, ("generate_resource_hash(): wrong number of args (#{args.length}; must be at least 2)")
    end

    ohash   = args[0]
    prefix  = args[1]
    #rehash = Hash.new

    rehash = Hash[ohash.map{|k,v| ["#{prefix}#{k}",v]}]

  end
end
