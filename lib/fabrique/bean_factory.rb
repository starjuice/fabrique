module Fabrique

  class BeanFactory

    def initialize(application_context)
      @ctx = application_context
    end

    def get_bean(bean_name)
      type_name = @ctx["beans"][bean_name]["class"]
      type = Module.const_get(type_name)
      arguments = @ctx["beans"][bean_name]["arguments"]
      type.new(*arguments)
    end

  end

end
