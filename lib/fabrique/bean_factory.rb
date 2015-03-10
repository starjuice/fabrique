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
        arguments = defn["constructor_args"] #? || []
        factory_method = defn["factory_method"] || "new"
        if factory_method == "itself"
          # Support RUBY_VERSION < 2.2.0 (missing Kernel#itself)
          template
        else
          bean = if arguments.respond_to?(:keys)
            arguments = arguments.inject({}) { |m, (k, v)| m[k.intern] = resolve_value(v); m }
            template.send(factory_method, arguments)
          else
            arguments = arguments.map { |v| resolve_value(v) } if arguments.respond_to?(:map)
            template.send(factory_method, *arguments)
          end
          bean.tap do |b|
            properties = defn["properties"] || []
            properties.each do |k, v|
              b.send("#{k}=", resolve_value(v))
            end
          end
        end
      end

      def resolve_value(v)
        if v.respond_to?(:keys)
          if v["bean"]
            get_bean(v["bean"])
          else
            type = v["type"]
            v = v["value"]
            case type
            when "String"
              v.to_s
            when "Integer"
              v.to_i
            when "Float"
              v.to_f
            end
          end
        else
          v
        end
      end

  end

end
