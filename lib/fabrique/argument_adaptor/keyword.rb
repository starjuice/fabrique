module Fabrique

  module ArgumentAdaptor

    class Keyword

      def adapt(properties = nil)
        if properties.nil?
          []
        else
          [properties]
        end
      end

    end

  end

end
