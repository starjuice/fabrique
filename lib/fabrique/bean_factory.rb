module Fabrique

  class BeanFactory

    def initialize(application_context)
      @ctx = application_context
    end

    def get_bean(bean_name)
      template_name = @ctx["beans"][bean_name]["template"]
      template = Module.const_get(template_name)
      arguments = @ctx["beans"][bean_name]["arguments"]
      case @ctx["beans"][bean_name]["method"]
      when "constructor"
        if arguments.respond_to?(:keys)
          arguments = arguments.inject({}) { |m, (k, v)| m[k.intern] = v; m }
          template.new(arguments)
        else
          template.new(*arguments)
        end
      when "identity"
        template
      end
    end

  end

end
