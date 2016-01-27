require "thread"

module Fabrique

  class BeanFactory
    attr_reader :registry, :singletons

    def initialize(registry)
      @registry = registry
      @registry.validate!
      @singletons = {}
      @semaphore = Mutex.new
    end

    def get_bean(bean_name)
      @semaphore.synchronize do
        get_bean_unsynchronized(bean_name)
      end
    end

    private

      def get_bean_unsynchronized(bean_name)
        defn = @registry.get_definition(bean_name)

        if defn.singleton? and singleton = @singletons[bean_name]
          return singleton
        end

        get_bean_by_definition(defn).tap do |bean|
          if defn.singleton?
            @singletons[bean_name] = bean
          end
        end
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
        else
          defn.type
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
        bean.tap do |b|
          defn.properties.each do |k, v|
            b.send("#{k}=", resolve_bean_references(v))
          end
        end
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
