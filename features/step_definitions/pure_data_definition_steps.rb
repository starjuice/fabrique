Given(/^I have a plain data application context definition:$/) do |string|
  @context_definition = YAML.safe_load(string, [Symbol])["beans"]
end

When(/^I request a bean factory for the plain data application context$/) do
  begin
    @bean_factory = Fabrique::BeanFactory.new(@context_definition)
  rescue Exception => e
    $stderr.puts "DEBUG @bean_factory_request_exception -> #{e.inspect}\n\t#{e.backtrace.join("\n\t")}" if ENV["DEBUG"]
    @bean_factory_request_exception = e
  end
end

