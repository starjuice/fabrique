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

    def initialize(path_or_string)
      super load_yaml path_or_string
    end

    private

    def load_yaml(path_or_string)
      if path_or_string.is_a?(String) and path_or_string =~ /\A---\r?\n/
        YAML.load(path_or_string)
      else
        YAML.load_file(path_or_string)
      end
    end

  end

end
