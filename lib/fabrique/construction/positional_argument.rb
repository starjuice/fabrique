module Fabrique

  module Construction

    class PositionalArgument

      def initialize(*arguments)
        @arguments = arguments
      end

      def call(type, properties)
        type.new(*@arguments.inject([]) { |m, arg| m << properties[arg] })
      end

    end

  end

end
