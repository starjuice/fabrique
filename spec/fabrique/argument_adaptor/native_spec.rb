require "spec_helper"

describe Fabrique::ArgumentAdaptor::Native do

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
        properties = {size: "small", color: "red", shape: "dot"}
        expect(subject.adapt(properties)).to eql [properties]
      end

    end

  end

end
