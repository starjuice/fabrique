module Fabrique

  class BeanFactory

    def initialize(application_context)
      @ctx = application_context
    end

    def get_bean(bean_name)
      type_name = @ctx["beans"][bean_name]["class"]
      type = Module.const_get(type_name)
      arguments = @ctx["beans"][bean_name]["arguments"]
      if arguments.respond_to?(:keys)
        arguments = arguments.inject({}) { |m, (k, v)| m[k.intern] = v; m }
        type.new(arguments)
      else
        type.new(*arguments)
      end
    end

  end

end
