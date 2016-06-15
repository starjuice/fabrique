require "tsort"
require_relative "bean_definition"
require_relative "cyclic_bean_dependency_error"

module Fabrique

  class BeanDefinitionRegistry
    include TSort

    def initialize(definitions)
      @defs = definitions.map { |d| d.is_a?(BeanDefinition) ? d : BeanDefinition.new(d) }
    end

    def get_definition(bean_name)
      @defs.detect { |d| d.id == bean_name }
    end

    def get_definitions
      @defs
    end

    def get_gem_definitions
      @defs.collect(&:gem).compact
    end

    def validate!
      tsort
    rescue TSort::Cyclic => e
      raise CyclicBeanDependencyError.new(e.message.gsub(/topological sort failed/, "cyclic bean dependency error"))
    end

    private

      def tsort_each_child(node, &block)
        defn = get_definition(node)
        deps = defn.dependencies
        deps.map { |dep| dep.bean }.each(&block)
      end

      def tsort_each_node
        @defs.each do |dep|
          yield dep.id
        end
      end

  end

end

