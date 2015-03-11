require "yaml"

Given(/^I have a YAML application context definition:$/) do |string|
  @application_context = YAML.load(string)
end

When(/^I request a bean factory for the application context$/) do
  @bean_factory = Fabrique::BeanFactory.new(@application_context)
end

When(/^I request the "(.*?)" bean from the bean factory$/) do |bean_name|
  @bean = @bean_factory.get_bean(bean_name)
end

Then(/^the bean has "(.*?)" set to "(.*?)"$/) do |attr, value|
  expect(@bean.send(attr)).to eql value
end

Then(/^the bean has "(.*?)" that is the Integer "(.*?)"$/) do |attr, int_value|
  expect(@bean.send(attr)).to eql int_value.to_i
end

Then(/^the "(.*?)" bean has "(.*?)" set to the "(.*?)" bean$/) do |parent, attr, child|
  parent = @bean_factory.get_bean(parent)
  child = @bean_factory.get_bean(child)
  expect(parent.send(attr)).to eql child
end

Then(/^the "(.*?)" bean has "(.*?)" set to "(.*?)"$/) do |bean_name, attr, value|
  bean = @bean_factory.get_bean(bean_name)
  expect(bean.send(attr)).to eql(value)
end

Then(/^I get the same object when I request the "(.*?)" bean again$/) do |bean_name|
  new_reference = @bean_factory.get_bean(bean_name)
  expect(new_reference.object_id).to eql @bean.object_id
end

Then(/^I get a different object when I request the "(.*?)" bean again$/) do |bean_name|
  new_reference = @bean_factory.get_bean(bean_name)
  expect(new_reference.object_id).to_not eql @bean.object_id
end

Then(/^I get a cyclic bean reference error when I request the "(.*?)" bean from the bean factory$/) do |bean_name|
  expect { @bean_factory.get_bean(bean_name) }.to raise_error(/cyclic bean reference/)
end
