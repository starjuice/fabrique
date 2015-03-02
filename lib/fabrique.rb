Dir[File.join(File.dirname(__FILE__), "fabrique", "*.rb")].each { |f| require_relative f }
Dir[File.join(File.dirname(__FILE__), "fabrique", "construction", "*.rb")].each { |f| require_relative f }
Dir[File.join(File.dirname(__FILE__), "fabrique", "constructor", "*.rb")].each { |f| require_relative f }
Dir[File.join(File.dirname(__FILE__), "fabrique", "argument_adaptor", "*.rb")].each { |f| require_relative f }

module Fabrique
end
