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

    def self.parse(yaml)
      YAML.load(yaml)
    end

  end

end
