module Fabrique

  class GemLoader

    def initialize(gem_definitions)
      @gem_defs = gem_definitions
      deps = @gem_defs.collect(&:dependency).reject { |x| not x.matching_specs.empty? }
      @gem_set = Gem::RequestSet.new(*deps)
    end

    def load_gems
      require "rubygems/dependency_installer"
      @gem_set.resolve
      specs = @gem_set.install(Gem::DependencyInstaller::DEFAULT_OPTIONS.merge(document: []))
      specs.each do |spec|
        spec.activate
      end
      @gem_defs.collect(&:required_as).each { |x| require x }
    rescue Gem::DependencyResolutionError, Gem::UnsatisfiableDependencyError => e
      raise Fabrique::GemDependencyError.new(e.message)
    end

  end

end
