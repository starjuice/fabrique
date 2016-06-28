module Fabrique

  module BeanFactoryContextParser

    def self.parse_registry(context)
      bean_definition_registry deep_map_dsl beans_node context
    end

    def self.beans_node(context)
      if context.is_a?(Hash) and context.key?("beans")
        context["beans"]
      else
        raise "Bean context contains no top-level beans node"
      end
    end

    def self.bean_definition_registry(beans)
      if beans.is_a?(BeanDefinitionRegistry)
        beans
      elsif beans.is_a?(Array)
        BeanDefinitionRegistry.new(beans)
      else
        raise "Beans must be an Array or a BeanDefinitionRegistry"
      end
    end

    def self.deep_map_dsl(o)
      if o.is_a?(Hash) and o.key?("!bean/ref")
        BeanReference.new(o["!bean/ref"])
      elsif o.is_a?(Hash) and o.key?("!bean")
        BeanDefinition.new(deep_map_dsl(o["!bean"]))
      elsif o.is_a?(Hash) and o.key?("!bean/property_ref")
        BeanPropertyReference.new(o["!bean/property_ref"])
      elsif o.is_a?(Hash)
        o.map { |k, v| [k, deep_map_dsl(v)] }.to_h
      elsif o.is_a?(Array)
        o.map { |v| deep_map_dsl(v) }
      else
        o
      end

    end

  end

end
