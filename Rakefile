task :default => :test

desc 'run the unit tests'
task :test do
  query = File.dirname(__FILE__) << '/test/*.test.rb'
  Dir[query].each { |filename| require filename }
end

desc 'irb session with env loaded'
task :console do
  dir = File.dirname(__FILE__)
  requirements = String.new
  requirements << "-r #{dir}/test/_helper.rb"
  system "irb -f #{requirements}"
end