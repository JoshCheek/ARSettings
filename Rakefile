task :default do
  query = File.dirname(__FILE__) << '/test/*.test.rb'
  Dir[query].each { |filename| require filename }
end