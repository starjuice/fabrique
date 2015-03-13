require "yaml"
require_relative "bean_definition_registry"
require_relative "bean_definition"
require_relative "bean_factory"
require_relative "bean_reference"
require_relative "bean_property_reference"

module Fabrique

  YAML.add_domain_type("starjuice.net,2015-03-13", "beans") do |type, value|
    BeanDefinitionRegistry.new(value)
  end

  YAML.add_domain_type("starjuice.net,2015-03-13", "bean") do |type, value|
    BeanDefinition.new(value)
  end

  YAML.add_domain_type("starjuice.net,2015-03-13", "bean/ref") do |type, value|
    BeanReference.new(value)
  end

  YAML.add_domain_type("starjuice.net,2015-03-13", "bean/property_ref") do |type, value|
    BeanPropertyReference.new(value)
  end

  class YamlBeanFactory < BeanFactory

    def initialize(pathname)
      data = YAML.load_file(pathname)
      if data.respond_to?(:keys) and data["beans"]
        beans = data["beans"]
      else
        raise "YAML contains no top-level beans node"
      end

      if beans.is_a?(BeanDefinitionRegistry)
        super(beans)
      elsif beans.is_a?(Array)
        super(BeanDefinitionRegistry.new(beans))
      else
        raise "YAML top-level beans node must be an Array or a #{BeanDefinitionRegistry}"
      end
    end

  end

end
