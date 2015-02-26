require "spec_helper"

describe Fabrique::PluginRegistry do

  subject { described_class.new("Test Plugin Factory") }

  describe "#register(id, type, constructor)" do

    let(:constructor) { spy("constructor") }

    it "applies the strategy pattern to construction" do
      subject.register(:my_plugin, type = Class.new, constructor)
      subject.acquire(:my_plugin, {some: "properties"})
      expect(constructor).to have_received(:call).with(type, {some: "properties"})
    end

    it "returns true on success (to avoid leaking registration internals)" do
      expect(subject.register(:my_plugin, Class.new, constructor)).to be true
    end

    context "when the unique identity has already been registered" do

      let(:existing_type) { Object.new }
      before(:each) { subject.register(:existing, existing_type, constructor) }

      it "raises an ArgumentError" do
        expect {
          subject.register(:existing, Object.new, double("constructor").as_null_object)
        }.to raise_error(ArgumentError, /#{existing_type} already registered/)
      end

      it "leaves the original registration intact" do
        begin
          subject.register(:existing, Object.new, double("constructor").as_null_object)
        rescue
        end
        subject.acquire(:existing)
        expect(constructor).to have_received(:call).with(existing_type)
      end

    end

  end

end
