Puppet::Parser::Functions.newfunction :load_data, :type => :statement do |args|
    if args.length == 1
        klass = args[0]
    else
        klass = resource.title
    end

    datadir = "/Users/luke/git/clients/redhat/data"

    dirs = datadir.split("/") + klass.split("::")
    name = dirs.pop + ".yaml"
    dir = dirs.join("/")
    path = File.join(dir, name)

    unless FileTest.exist?(path)
        raise ArgumentError, "Could not find data file for class %s" % klass
    end

    params = YAML.load_file(path)

    raise ArgumentError, "Data for %s is not a hash" % klass unless params.is_a?(Hash)

    params.each do |param, value|
        setvar(param, value)
    end
end
