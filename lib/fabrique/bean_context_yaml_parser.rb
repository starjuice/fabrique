require "yaml"
require_relative "bean_definition_registry"
require_relative "bean_definition"
require_relative "bean_reference"

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

  class BeanContextYamlParser

    def self.parse(s)
      yaml = YAML.load(s)
      if yaml.respond_to?(:keys) and yaml["beans"]
        beans = yaml["beans"]
      else
        raise "YAML contains no top-level beans node"
      end

      if beans.is_a?(BeanDefinitionRegistry)
        beans
      elsif beans.is_a?(Array)
        BeanDefinitionRegistry.new(beans)
      else
        raise "YAML top-level beans node must be an Array or a #{BeanDefinitionRegistry}"
      end
    end

  end

end
