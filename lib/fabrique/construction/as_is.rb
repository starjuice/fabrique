module Fabrique

  module Construction

    class AsIs

      def call(type, properties = nil)
        raise ArgumentError.new("unexpected properties for as-is construction") unless (properties.nil? or properties.empty?)
        type
      end

    end

  end

end
