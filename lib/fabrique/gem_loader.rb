module Fabrique

  class GemLoader

    def initialize(definitions)
      @gem_defs = definitions.collect(&:gem).compact
    end

    def load_gems
      require "rubygems/dependency_installer"
      @gem_dependencies ||= resolve_gem_dependencies
      specs = @gem_dependencies.install(Gem::DependencyInstaller::DEFAULT_OPTIONS.merge(document: []))
      specs.each do |spec|
        spec.activate
      end
      @gem_defs.each do |gem|
        require(gem["require"] || gem["name"])
      end
    end

    def validate!
      resolve_gem_dependencies
    end

    def resolve_gem_dependencies
      deps = @gem_defs.map { |x| Gem::Dependency.new(x["name"], x["version"] || Gem::Requirement.default) }
      @gem_dependencies = Gem::RequestSet.new(*deps).tap { |set| set.resolve }
    rescue Gem::DependencyError => e
      raise GemDependencyError.new(e.message)
    end

  end

end
