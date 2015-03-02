Dir[File.join(File.dirname(__FILE__), "test", "**", "*.rb")].each { |f| require_relative f }

module Fabrique

  module Test
  end

end
