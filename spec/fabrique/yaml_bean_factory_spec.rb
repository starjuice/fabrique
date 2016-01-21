require "spec_helper"
require "tempfile"

describe Fabrique::YamlBeanFactory do

  let(:yaml_context_string) {
    "---\n" \
    "beans: !beans\n" \
    "- !bean\n" \
    "  id: simple_object\n" \
    "  class: Fabrique::Test::Fixtures::Constructors::ClassWithDefaultConstructor\n"
  }

  after(:each) do
    @tmpfile.unlink if @tmpfile
  end

  it "constructs from a YAML application context definition file" do
    @tmpfile = Tempfile.open('fabrique')
    @tmpfile.write yaml_context_string
    @tmpfile.close

    bean_factory = Fabrique::YamlBeanFactory.new(@tmpfile.path)
    expect(bean_factory.get_bean('simple_object')).to be_a(Fabrique::Test::Fixtures::Constructors::ClassWithDefaultConstructor)
  end

  it "constructs from a YAML application context definition string" do
    bean_factory = Fabrique::YamlBeanFactory.new(yaml_context_string)
    expect(bean_factory.get_bean('simple_object')).to be_a(Fabrique::Test::Fixtures::Constructors::ClassWithDefaultConstructor)
  end

end
