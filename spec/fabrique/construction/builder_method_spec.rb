require "spec_helper"
require "fabrique/test"

describe Fabrique::Construction::BuilderMethod do

  describe "call(type, properties = nil)" do

    context "when initialized with a builder method name and builder runner block" do

      subject do
        described_class.new(:build) do |builder, properties|
          builder.size = properties[:size]
          builder.color = properties[:color]
          builder.shape = properties[:shape]
        end
      end

      it "calls the builder method on the type and yields the builder and the specified properties to the builder runner block" do
        o = subject.call(Fabrique::Test::Fixtures::Constructors::ClassWithBuilderMethod, size: "huge", color: "black", shape: "hole")
        expect(o.size).to eql "huge"
        expect(o.color).to eql "black"
        expect(o.shape).to eql "hole"
      end

    end

  end

end
