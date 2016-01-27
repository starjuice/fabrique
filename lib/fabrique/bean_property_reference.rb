module Fabrique

  class BeanPropertyReference
    attr :bean, :property

    def initialize(bean_property)
      chain = bean_property.split('.')
      @bean = chain.first
      @property_chain = chain.drop(1)
      @property = @property_chain.join('.')
    end

    def resolve(bean)
      @property_chain.inject(bean) { |acc, property| acc.send(property) }
    end

  end

end
