require "spec_helper"

describe Fabrique::Construction::Default do

  describe "call(type, properties = nil)" do

    it "calls type.new() without arguments" do
      constructed = subject.call(type = Object)
      expect(constructed.class).to eql type
    end

    it "accepts optional properties to support construction interface" do
      constructed = subject.call(type = Object, {})
      expect(constructed.class).to eql type
    end

  end

end
