module Fabrique

  module Construction

    class Default

      def call(type)
        type.new
      end

    end

  end

end
