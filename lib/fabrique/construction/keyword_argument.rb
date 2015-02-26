module Fabrique

  module Construction

    # TODO Derive from PropertiesHash
    class KeywordArgument

      def call(type, properties)
        type.new(properties)
      end

    end

  end

end
