module Fabrique

  class PluginRegistry

    def initialize(name)
      @name = name
      @registrations = []
    end

    def register(id, type, constructor)
      if existing = find_registration(id)
        raise ArgumentError, "could not register #{type} as #{id} in #{@name}: #{existing.type} already registered as #{id}"
      end
      @registrations << Registration.new(id, type, constructor)
      true
    end

    def acquire(id, properties = nil)
      if registration = find_registration(id)
        registration.call_constructor(properties)
      else
        raise ArgumentError, "#{id} not registered in #{@name}"
      end
    end

    private

      def find_registration(id)
        @registrations.detect { |r| r.id == id }
      end

      def unregister(id)
        @registrations.delete(find_registration(id))
      end

      class Registration

        attr_reader :id, :type, :constructor

        def initialize(id, type, constructor)
          @id, @type, @constructor = id, type, constructor
        end

        def call_constructor(properties = nil)
          # TODO Push conditional into construction helpers
          if properties.nil?
            @constructor.call(@type)
          else
            @constructor.call(@type, properties)
          end
        end

      end
  end

end
