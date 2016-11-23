require "spec_helper"

describe Fabrique::BeanFactory do

  it "raises a missing bean error when asked for a nonexistent bean" do
    bean_factory = Fabrique::BeanFactory.new(Fabrique::BeanDefinitionRegistry.new([]))
    expect {
      bean_factory.get_bean("nonexistent")
    }.to raise_error Fabrique::MissingBeanError, /nonexistent/
  end

end
