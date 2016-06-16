module Fabrique

  class GemDefinition

    attr_reader :dependency, :required_as

    def initialize(defn)
      @dependency = Gem::Dependency.new(defn["name"], defn["version"] || Gem::Requirement.default)
      @required_as = defn["require"] || defn["name"]
    end

  end

end

