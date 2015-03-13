module Fabrique

  class BeanPropertyReference
    attr :bean, :property

    def initialize(bean_property)
      @bean, @property = bean_property.split('.')
    end
  end

end
