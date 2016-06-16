require "tempfile"

After do
  if defined?(@tmpfile) and File.exists?(@tmpfile.path)
    @tmpfile.unlink
  end
end

Given(/^I have a YAML application context definition:$/) do |string|
  @tmpfile = Tempfile.open('fabrique')
  @tmpfile.write string
  @tmpfile.close
end

When(/^I request a bean factory for the application context$/) do
  begin
    @bean_factory = Fabrique::YamlBeanFactory.new(@tmpfile.path)
  rescue Exception => e
    $stderr.puts "DEBUG @bean_factory_request_exception -> #{e.inspect}\n\t#{e.backtrace.join("\n\t")}" if ENV["DEBUG"]
    @bean_factory_request_exception = e
  end
end

When(/^I request the "(.*?)" bean from the bean factory$/) do |bean_name|
  @bean = @bean_factory.get_bean(bean_name)
end

Then(/^the bean has "(.*?)" set to "(.*?)"$/) do |attr, value|
  expect(@bean.send(attr)).to eql value
end

Then(/^the bean's "(.*?)" is an object with "(.*?)" set to "(.*?)"$/) do |attr, child_attr, value|
  expect(@bean.send(attr).send(child_attr)).to eql value
end

Then(/^the bean has "(.*?)" that is the Integer "(.*?)"$/) do |attr, int_value|
  expect(@bean.send(attr)).to eql int_value.to_i
end

Then(/^the "(.*?)" bean has "(.*?)" that is the Integer (\d+)$/) do |bean_name, attr, int_value|
  bean = @bean_factory.get_bean(bean_name)
  expect(bean.send(attr)).to eql int_value.to_i
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

Then(/^I get a cyclic bean dependency error$/) do
  expect(@bean_factory_request_exception).to be_a Fabrique::CyclicBeanDependencyError
end

Then(/^the "(.*?)" and "(.*?)" beans share the same "(.*?)"$/) do |bean1_name, bean2_name, shared_property|
  bean1 = @bean_factory.get_bean(bean1_name)
  bean2 = @bean_factory.get_bean(bean2_name)
  expect(bean1.send(shared_property).object_id).to eql bean2.send(shared_property).object_id
end

Then(/^the "(.*?)" and "(.*?)" beans each have their own "(.*?)"$/) do |bean1_name, bean2_name, own_property|
  bean1 = @bean_factory.get_bean(bean1_name)
  bean2 = @bean_factory.get_bean(bean2_name)
  expect(bean1.send(own_property).object_id).to_not eql bean2.send(own_property).object_id
end

Given(/^the "(.*?)" gem is not installed$/) do |gem|
  require "rubygems/uninstaller"
  dep = Gem::Dependency.new(gem, Gem::Requirement.default)
  specs = dep.matching_specs
  specs.each do |spec|
    Gem::Uninstaller.new(spec).uninstall
  end
end

Given(/^the "([^"]*)" gem is already installed$/) do |arg1|
  %x{ gem install --no-ri --no-rdoc fixtures/local_only-0.1.0.gem }
end

When(/^I request that bean dependency gems be loaded for the bean factory$/) do
  begin
    @bean_factory.load_gem_dependencies
  rescue Exception => e
    $stderr.puts "DEBUG @bean_factory_load_gem_dependencies_exception -> #{e.inspect}\n\t#{e.backtrace.join("\n\t")}" if ENV["DEBUG"]
    @bean_factory_load_gem_dependencies_exception = e
  end
end

Then(/^I get a gem dependency error$/) do
  expect(@bean_factory_load_gem_dependencies_exception).to be_a Fabrique::GemDependencyError
end

When(/^I request a dictionary of all beans$/) do
  @dictionary = @bean_factory.to_h
end

Then(/^the dictionary maps "([^"]*)" to the "([^"]*)" bean$/) do |dictionary_key, bean_name|
  expect(@dictionary[dictionary_key]).to eql @bean_factory.get_bean(bean_name)
end
