module Fabrique

  class BeanDefinition
    attr_reader :constructor_args, :factory_method, :gem, :id, :properties, :type

    def initialize(attrs = {})
      @id = attrs["id"]
      @type = attrs["class"]
      @gem = attrs["gem"]
=begin
        dep = Gem::Dependency.new(@gem["name"], @gem["version"] || Gem::Requirement.default)
        specs = dep.matching_specs
        if specs.empty?
          $stderr.puts "DEBUG: installing #{dep.inspect}"
          set = Gem::RequestSet.new(dep)
          set.resolve
          require "rubygems/dependency_installer"
          specs = set.install(Gem::DependencyInstaller::DEFAULT_OPTIONS.merge(document: []))
        end
        spec = specs.max_by(&:version)
        $stderr.puts "DEBUG: activating #{spec.inspect}"
        spec.activate
        require(@gem["require"] || spec.name)
=end
      @constructor_args = attrs["constructor_args"] || []
      @constructor_args = keywordify(@constructor_args) if @constructor_args.is_a?(Hash)
      @properties = attrs["properties"] || {}
      @scope = attrs["scope"] || "singleton"
      @factory_method = attrs["factory_method"] || "new"
    end

    def dependencies
      (accumulate_dependencies(@type) + accumulate_dependencies(@constructor_args) + accumulate_dependencies(@properties)).uniq
    end

    def singleton?
      @scope == "singleton"
    end

    private

      def keywordify(args)
        args.inject({}) { |m, (k, v)| k = k.intern rescue k; m[k.intern] = v; m }
      end

      def accumulate_dependencies(data, acc = [])
        if data.is_a?(Hash)
          accumulate_dependencies(data.values, acc)
        elsif data.is_a?(Array)
          data.each do |o|
            accumulate_dependencies(o, acc)
          end
        elsif data.is_a?(BeanReference) or data.is_a?(BeanPropertyReference)
          acc << data
        end
        acc
      end

  end

end
