require "yaml"
require_relative "bean_definition"
require_relative "bean_definition_registry"
require_relative "bean_reference"

YAML.add_builtin_type("bean") do |type, value|
  Fabrique::BeanDefinition.new(value)
end

YAML.add_builtin_type("beans") do |type, value|
  Fabrique::BeanDefinitionRegistry.new(value)
end

YAML.add_builtin_type("bean/ref") do |type, value|
  Fabrique::BeanReference.new(value)
end

module Fabrique

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
