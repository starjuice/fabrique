require "thread"

module Fabrique

  class BeanFactory
    attr_reader :registry, :singletons

    def initialize(beans)
      @registry = bean_definition_registry beans
      @registry.validate!
      @gem_loader = GemLoader.new(@registry.get_gem_definitions)
      @singletons = {}
      @semaphore = Mutex.new
    end

    def get_bean(bean_name)
      @semaphore.synchronize do
        get_bean_unsynchronized(bean_name)
      end
    end

    def load_gem_dependencies
      @gem_loader.load_gems
    end

    def to_h
      @semaphore.synchronize do
        @registry.get_definitions.map { |defn| [defn.id, get_bean_unsynchronized(defn.id)] }.to_h
      end
    end

    private

      def bean_definition_registry(beans)
        if beans.is_a?(BeanDefinitionRegistry)
          beans
        elsif beans.is_a?(Array)
          BeanDefinitionRegistry.new(beans)
        else
          raise BeanDefinitionError, "Bean definition registry must be an Array or a #{BeanDefinitionRegistry}"
        end
      end

      def get_bean_unsynchronized(bean_name)
        defn = @registry.get_definition(bean_name)

        if defn.singleton? and singleton = @singletons[bean_name]
          return singleton
        end

        bean = get_bean_by_definition(defn)
        if defn.singleton?
          @singletons[bean_name] = bean
        end
        bean
      end

      def get_bean_by_definition(defn)
        if defn.factory_method == "itself"
          return get_factory(defn)
        end

        bean = constructor_injection(defn)
        property_injection(bean, defn)
      end

      def get_factory(defn)
        if defn.type.is_a?(BeanReference)
          get_bean_unsynchronized(defn.type.bean)
        elsif defn.type.is_a?(Module)
          defn.type
        else
          Module.const_get(defn.type)
        end
      end

      def constructor_injection(defn)
        args = resolve_bean_references(defn.constructor_args)
        factory = get_factory(defn)
        if args.respond_to?(:keys)
          bean = factory.send(defn.factory_method, args)
        else
          bean = factory.send(defn.factory_method, *args)
        end
      end

      def property_injection(bean, defn)
        defn.properties.each do |k, v|
          bean.send("#{k}=", resolve_bean_references(v))
        end
        bean
      end

      def resolve_bean_references(data)
        if data.is_a?(Hash)
          data.inject({}) do |memo, (k, v)|
            memo[k] = resolve_bean_references(v)
            memo
          end
        elsif data.is_a?(Array)
          data.inject([]) do |acc, v|
            acc << resolve_bean_references(v)
          end
        elsif data.is_a?(BeanDefinition)
          get_bean_by_definition(data)
        elsif data.is_a?(BeanReference)
          get_bean_unsynchronized(data.bean)
        elsif data.is_a?(BeanPropertyReference)
          data.resolve(get_bean_unsynchronized(data.bean))
        else
          data
        end
      end

  end

end
