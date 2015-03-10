module Fabrique

  class BeanFactory

    # TODO Take a BeanDefinitionRegistry
    def initialize(bean_config)
      @cfg = bean_config
      @singletons = {}
    end

    def get_bean(bean_name)
      defn = get_bean_definition(bean_name)
      case (defn["scope"] || "singleton")
      when "prototype"
        build_bean(defn)
      when "singleton"
        @singletons[bean_name] ||= build_bean(defn)
      end
    end

    private

      def get_bean_definition(bean_name)
        @cfg["beans"][bean_name]
      end

      def build_bean(defn)
        template_name = defn["template"]
        template = Module.const_get(template_name)
        case (defn["method"] or "constructor")
        when "constructor"
          arguments = defn["constructor_args"]
          bean = if arguments.respond_to?(:keys)
            arguments = arguments.inject({}) { |m, (k, v)| m[k.intern] = interpolate(v); m }
            template.new(arguments)
          else
            arguments = arguments.map { |v| interpolate(v) } if arguments.respond_to?(:map)
            template.new(*arguments)
          end
          bean.tap do |b|
            properties = defn["properties"]
            properties.each do |k, v|
              b.send("#{k}=", v)
            end
          end
        when "identity"
          template
        end
      end

      def interpolate(v)
        if v =~ /^bean:(.+)$/
          bean_name = $1
          get_bean(bean_name)
        else
          v
        end
      end

  end

end
