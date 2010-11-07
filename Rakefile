task :default => :test


desc 'run the unit tests'
task :test do
  query = File.dirname(__FILE__) << '/test/*_test.rb'
  Dir[query].each { |filename| require filename }
end


desc 'irb session with env loaded'
task :console do
  dir = File.dirname(__FILE__)
  requirements = String.new
  requirements << "-r #{dir}/test/_helper.rb"
  system "irb -f #{requirements}"
end


require "rubygems"
require "rake/gempackagetask"
require "rake/rdoctask"

require "rake/testtask"
Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList["test/**/*_test.rb"]
  t.verbose = true
end



# This builds the actual gem. For details of what all these options
# mean, and other ones you can add, check the documentation here:
#
#   http://rubygems.org/read/chapter/20
#
spec = Gem::Specification.new do |s|

  # Change these as appropriate
  s.name              = "arsettings"
  s.version           = "1.0.0"
  s.author            = "Joshua Cheek"
  s.email             = "josh.cheek@gmail.com"
  s.homepage          = "https://github.com/JoshCheek/ARSettings"
  s.summary           = "Settings for ActiveRecord projects (ie Rails)"
  s.description       = "ActiveRecord has a lot of support for tables of similar values. But what about those one time only values, like site settings? This is what ARSettings is intended for. One line to add settings to your ActiveRecord classes. Two to non-ActiveRecord classes. And you can have settings that are not defined on any class as well."

  s.has_rdoc          = true
  s.extra_rdoc_files  = %w(Readme.mdown)
  s.rdoc_options      = %w(--main Readme.mdown)

  # Add any extra files to include in the gem
  s.files             = %w(Rakefile Readme.mdown) + Dir.glob("{test,lib/**/*}")
  s.require_paths     = ["lib"]

  # If you want to depend on other gems, add them here, along with any
  # relevant versions
  s.add_dependency("activerecord", ">= 2.3.8")

  # If your tests use any gems, include them here
  s.add_development_dependency("sqlite-ruby", ">= 1.3.1")
end

# This task actually builds the gem. We also regenerate a static
# .gemspec file, which is useful if something (i.e. GitHub) will
# be automatically building a gem for this project. If you're not
# using GitHub, edit as appropriate.
#
# To publish your gem online, install the 'gemcutter' gem; Read more 
# about that here: http://gemcutter.org/pages/gem_docs
Rake::GemPackageTask.new(spec) do |pkg|
  pkg.gem_spec = spec
end

desc "Build the gemspec file #{spec.name}.gemspec"
task :gemspec do
  file = File.dirname(__FILE__) + "/#{spec.name}.gemspec"
  File.open(file, "w") {|f| f << spec.to_ruby }
end

task :package => :gemspec

# Generate documentation
Rake::RDocTask.new do |rd|
  rd.main = "Readme.mdown"
  rd.rdoc_files.include("Readme.mdown", "lib/**/*.rb")
  rd.rdoc_dir = "rdoc"
end

desc 'Clear out RDoc and generated packages'
task :clean => [:clobber_rdoc, :clobber_package] do
  rm "#{spec.name}.gemspec"
end

# desc 'generate docs'
# task :doc do
#   system "rdoc --force-update --format=darkfish --main=lib/arsettings.rb --title=ARSettings --main=arsettings.rb #{File.dirname(__FILE__)}/lib"
# end
