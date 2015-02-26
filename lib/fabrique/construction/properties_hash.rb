module Fabrique

  module Construction

    class PropertiesHash

      def call(type, properties)
        type.new(properties)
      end

    end

  end

end
