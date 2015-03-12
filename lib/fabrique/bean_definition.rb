module Fabrique

  class BeanDefinition
    attr_reader :constructor_args, :factory_method, :id, :properties, :type

    def initialize(attrs = {})
      @id = attrs["id"]
      type_name = attrs["class"]
      @type = type_name.is_a?(Module) ? @type_name : Module.const_get(type_name)
      @constructor_args = attrs["constructor_args"] || []
      @constructor_args = keywordify(@constructor_args) if @constructor_args.is_a?(Hash)
      @properties = attrs["properties"] || {}
      @scope = attrs["scope"] || "singleton"
      @factory_method = attrs["factory_method"] || "new"
    end

    def dependencies
      (dependencies_of(@constructor_args) + dependencies_of(@properties)).uniq
    end

    def singleton?
      @scope == "singleton"
    end

    private

      def keywordify(args)
        args.inject({}) { |m, (k, v)| k = k.intern rescue k; m[k.intern] = v; m }
      end

      def dependencies_of(data, acc = [])
        if data.is_a?(Hash)
          dependencies_of(data.values, acc)
        elsif data.is_a?(Array)
          data.each do |o|
            dependencies_of(o, acc)
          end
        elsif data.is_a?(BeanReference)
          acc << data
        end
        acc
      end

  end

end
