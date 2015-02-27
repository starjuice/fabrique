require "spec_helper"

describe Fabrique::Construction::AsIs do

  describe "call(type, properties = nil)" do

    it "applies identity to the type" do
      constructed = subject.call(type = Object.new)
      expect(constructed.object_id).to eql type.object_id
    end

    it "accepts optional properties to support construction interface" do
      constructed = subject.call(type = Object.new, {})
      expect(constructed.object_id).to eql type.object_id
    end

    it "raises an ArgumentError if properties is specified and not empty" do
      expect { subject.call(Object.new, {some: "properties"}) }.to raise_error(ArgumentError, /unexpected properties/)
    end

  end

end
