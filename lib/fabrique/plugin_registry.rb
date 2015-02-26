module Fabrique

  class PluginRegistry

    def initialize(name)
      @name = name
      @registrations = {}
    end

    # TODO specify registration with existing id
    def register(id, type, constructor)
      @registrations[id] = {type: type, constructor: constructor}
    end

    # TODO specify acquiring an unknown id
    def acquire(id, properties = nil)
      registration = @registrations[id]
      # TODO Push conditional into construction helpers
      if properties.nil?
        registration[:constructor].call(registration[:type])
      else
        registration[:constructor].call(registration[:type], properties)
      end
    end

  end

end
