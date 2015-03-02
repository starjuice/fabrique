require "spec_helper"
require "fabrique/test"

describe Fabrique::ArgumentAdaptor::Keyword do

  let(:properties) { {size: "small", color: "red", shape: "dot"} }

  describe "#adapt(*properties)" do

    context "when called without properties" do

      it "returns an empty array" do
        expect(subject.adapt).to eql []
      end

    end

    context "when called with empty properties" do

      it "returns an empty hash in an empty array" do
        expect(subject.adapt({})).to eql [{}]
      end

    end

    context "when called with properties" do

      it "returns a hash containing the properties" do
        expect(subject.adapt(properties)).to eql [properties]
      end

    end

    it "supports properties hash constructors" do
      object = Fabrique::Test::Fixtures::Constructors::ClassWithPropertiesHashConstructor.new(*subject.adapt(properties))
      expect(object.size).to eql properties[:size]
      expect(object.color).to eql properties[:color]
      expect(object.shape).to eql properties[:shape]
    end

    it "supports keyword argument constructors" do
      object = Fabrique::Test::Fixtures::Constructors::ClassWithKeywordArgumentConstructor.new(*subject.adapt(properties))
      expect(object.size).to eql properties[:size]
      expect(object.color).to eql properties[:color]
      expect(object.shape).to eql properties[:shape]
    end

  end

end
