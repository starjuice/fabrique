module Fabrique

  class BeanFactory

    def initialize(application_context)
      @ctx = application_context
      @beans = {}
    end

    def get_bean(bean_name)
      @beans[bean_name] ||= build_bean(bean_name)
    end

    private

      def build_bean(bean_name)
        template_name = @ctx["beans"][bean_name]["template"]
        template = Module.const_get(template_name)
        arguments = @ctx["beans"][bean_name]["arguments"]
        case @ctx["beans"][bean_name]["method"]
        when "constructor"
          if arguments.respond_to?(:keys)
            arguments = arguments.inject({}) { |m, (k, v)| m[k.intern] = interpolate(v); m }
            template.new(arguments)
          else
            arguments = arguments.map { |v| interpolate(v) } if arguments.respond_to?(:map)
            template.new(*arguments)
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
