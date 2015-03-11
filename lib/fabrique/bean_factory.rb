require "thread"

module Fabrique

  class BeanDefinition
    attr_reader :constructor_args, :factory_method, :name, :properties, :scope

    def initialize(defn, name = nil)
      @name = defn["name"] || name or raise ArgumentError.new("missing name")
      @type_name = defn["class"] or raise ArgumentError.new("missing class")
      @scope = defn["scope"] || "singleton"
      @factory_method = defn["factory_method"] || "new"
      @constructor_args = formalize_properties(defn["constructor_args"] || [])
      @properties = formalize_properties(defn["properties"] || {})
    end

    def type
      @type_name.is_a?(Module) ? @type_name : Module.const_get(@type_name)
    end

    def singleton?
      @scope == "singleton"
    end

    def constructor_deps
      values = @constructor_args.respond_to?(:keys) ? @constructor_args.values : @constructor_args
      values.select { |v| v.bean_reference? }.map { |v| v.bean }
    end

    def property_deps
      @properties.values.select { |v| v.bean_reference? }.map { |v| v.bean }
    end

    private

      def formalize_properties(props)
        if props.respond_to?(:keys)
          props.inject({}) { |m, (k, v)| m[k] = formalize_value(v); m }
        else
          props.map { |v| formalize_value(v) }
        end
      end

      def formalize_value(v)
        v.is_a?(BeanPropertyDefinition) ? v : BeanPropertyDefinition.new(v)
      end

  end

  class BeanPropertyDefinition

    attr_reader :bean, :value

    def initialize(defn)
      if defn.respond_to?(:keys)
        @bean = defn["bean"]
        @value = derive_value(defn["type"], defn["value"]) unless bean_reference?
      else
        @value = defn
      end
    end

    def bean_reference?
      !@bean.nil?
    end

    private

      def derive_value(type, value)
        case type
        when "String"
          value.to_s
        when "Integer"
          value.to_i
        when "Float"
          value.to_f
        else
          raise TypeError.new("unknown bean property type #{type}")
        end
      end

  end

  class CyclicBeanDependencyError < RuntimeError
  end

  require "tsort"
  class BeanDefinitionRegistry
    include TSort

    def initialize(config)
      @defs = config["beans"].inject({}) { |acc, (k, v)| acc[k] = BeanDefinition.new(v, k); acc }
    end

    def get_definition(bean_name)
      @defs[bean_name]
    end

    def construction_path(bean_name)
      begin
        tsort.map { |p| get_definition(p) }
      rescue TSort::Cyclic => e
        raise CyclicBeanDependencyError.new(e.message.gsub(/topological sort failed/, "cyclic bean dependency error"))
      end
    end

    private

      def tsort_each_child(node, &block)
        get_definition(node).constructor_deps.map { |dep| @defs[dep].name }.each(&block)
      end

      def tsort_each_node
        @defs.each_value do |defn|
          yield defn.name
        end
      end

  end

  class BeanFactory

    # TODO Take a BeanDefinitionRegistry
    def initialize(config)
      @registry = BeanDefinitionRegistry.new(config)
      @singletons = {}
      @semaphore = Mutex.new
    end

    def get_bean(bean_name)
      @semaphore.synchronize do
        begin
          @bean_reference_cache = {}
          @registry.construction_path(bean_name).each do |defn|
            bean = get_bean_unsynchronized(defn.name)
            @bean_reference_cache[defn.name] = bean
          end
          @bean_reference_cache.each do |n, bean|
            property_injection(bean, @registry.get_definition(n))
          end
          @bean_reference_cache[bean_name]
        ensure
          @bean_reference_cache = nil
        end
      end
    end

    private

      def get_bean_definition(bean_name)
        @registry.values.detect { |defn| defn.name == bean_name }
      end

      def get_bean_unsynchronized(bean_name)
        defn = @registry.get_definition(bean_name)
        if defn.singleton?
          @singletons[bean_name] ||= build_bean(defn)
        else
          build_bean(defn)
        end
      end

      def build_bean(defn)
        if defn.factory_method == "itself"
          # Support RUBY_VERSION < 2.2.0 (missing Kernel#itself)
          defn.type
        else
          constructor_injection(defn)
        end
      end

      def constructor_injection(defn)
        if defn.constructor_args.respond_to?(:keys)
          args = defn.constructor_args.inject({}) { |m, (k, v)| m[k.intern] = resolve_bean_reference(v); m }
          defn.type.send(defn.factory_method, args)
        else
          args = defn.constructor_args.map { |v| resolve_bean_reference(v) }
          defn.type.send(defn.factory_method, *args)
        end
      end

      def property_injection(bean, defn)
        bean.tap do |b|
          defn.properties.each do |k, v|
            b.send("#{k}=", resolve_bean_reference(v))
          end
        end
      end

      def resolve_bean_reference(v)
        if v.bean_reference?
          @bean_reference_cache[v.bean] ||= get_bean_unsynchronized(v.bean)
        else
          v.value
        end
      end

  end

end
