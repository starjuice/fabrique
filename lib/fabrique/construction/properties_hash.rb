module Fabrique

  module Construction

    class PropertiesHash

      def call(type, properties = nil)
        if properties.nil?
          type.new
        else
          type.new(properties)
        end
      end

    end

  end

end
