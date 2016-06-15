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

    def validate!
      begin
        tsort
        resolve_gem_dependencies
      rescue TSort::Cyclic => e
        raise CyclicBeanDependencyError.new(e.message.gsub(/topological sort failed/, "cyclic bean dependency error"))
      rescue Gem::DependencyError => e
        raise GemDependencyError.new(e.message)
      end
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

      def resolve_gem_dependencies
        gems = @defs.collect(&:gem).compact
        deps = @defs.collect(&:gem).compact.map { |x| Gem::Dependency.new(x["name"], x["version"] || Gem::Requirement.default) }
        set = Gem::RequestSet.new(*deps)
        set.resolve # TODO cache for install phase?
        require "rubygems/dependency_installer"
        specs = set.install(Gem::DependencyInstaller::DEFAULT_OPTIONS.merge(document: []))
        specs.each do |spec|
          spec.activate
        end
        gems.each do |gem|
          require(gem["require"] || gem["name"])
        end
      end

  end

end

