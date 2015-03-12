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

        if defn.factory_method == "itself"
          # Support RUBY_VERSION < 2.2.0 (missing Kernel#itself)
          return defn.type
        end

        if defn.singleton? and singleton = @singletons[bean_name]
          return singleton
        end

        args = resolve_bean_references(defn.constructor_args)
        if args.respond_to?(:keys)
          bean = defn.type.send(defn.factory_method, args)
        else
          bean = defn.type.send(defn.factory_method, *args)
        end

        bean.tap do |b|
          defn.properties.each do |k, v|
            b.send("#{k}=", resolve_bean_references(v))
          end

          if defn.singleton?
            @singletons[bean_name] = bean
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
        elsif data.is_a?(BeanReference)
          get_bean_unsynchronized(data.bean)
        else
          data
        end
      end
  end

end
