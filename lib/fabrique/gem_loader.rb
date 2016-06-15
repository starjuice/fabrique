module Fabrique

  class GemLoader

    def initialize(gem_definitions)
      @gem_defs = gem_definitions
    end

    def load_gems
      require "rubygems/dependency_installer"
      deps = @gem_defs.collect(&:dependency)
      set = Gem::RequestSet.new(*deps)
      set.resolve
      specs = set.install(Gem::DependencyInstaller::DEFAULT_OPTIONS.merge(document: []))
      specs.each do |spec|
        spec.activate
      end
      @gem_defs.collect(&:required_as).each { |x| require x }
    rescue Gem::DependencyError => e
      raise GemDependencyError.new(e.message)
    end

  end

end
