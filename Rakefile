require "rubygems"
require "rake/gempackagetask"
require "rake/rdoctask"
# require "rake/testtask"


task :default => :test


namespace :test do
  desc 'create the gemsets'
  task :make_gemsets do
    sh File.dirname(__FILE__) << "/test/_make_gemsets.sh"
  end
  
  desc 'run the tests on current ruby/gemspec'
  task :crnt do
    require File.dirname(__FILE__) << "/test/_run_one"
  end
  
  desc 'check that all code is covered'
  task :rcov do
    sh File.dirname(__FILE__) << "/test/_rcov.sh"
  end
  
  desc 'run the tests on the supported rubies and gemsets'
  task :all do
    sh File.dirname(__FILE__) << "/test/_run_all.sh"
  end
  
  desc 'checks for code smells -- assumes you have reek installed'
  task :reek do
    sh File.dirname(__FILE__) << "/test/_reek.sh"
  end
end

desc 'synonym for test:crnt'
task :test => 'test:crnt'


desc 'irb session with env loaded'
task :console do
  dir = File.dirname(__FILE__)
  requirements = String.new
  requirements << "-r #{dir}/test/_helper.rb"
  system "irb -f #{requirements}"
end


# This builds the actual gem. For details of what all these options
# mean, and other ones you can add, check the documentation here:
#
#   http://rubygems.org/read/chapter/20
#
spec = Gem::Specification.new do |s|

  # Change these as appropriate
  s.name              = "arsettings"
  s.version           = "1.1.1"
  s.author            = "Joshua Cheek"
  s.email             = "josh.cheek@gmail.com"
  s.homepage          = "https://github.com/JoshCheek/ARSettings"
  s.summary           = "Settings for ActiveRecord projects (ie Rails)"
  s.description       = "ActiveRecord has a lot of support for tables of similar values. But what about those one time only values, like site settings? This is what ARSettings is intended for. One line to add settings to your ActiveRecord classes. Two to non-ActiveRecord classes. And you can have settings that are not defined on any class as well."

  s.has_rdoc          = true
  s.extra_rdoc_files  = %w(Readme.mdown)
  s.rdoc_options      = %w(--main Readme.mdown)

  # Add any extra files to include in the gem
  s.files             = %w(Rakefile Readme.mdown) + Dir.glob("{examples/**/*,test/**/*,lib/**/*}")
  s.require_paths     = ["lib"]

  # If you want to depend on other gems, add them here, along with any
  # relevant versions
  s.add_dependency("activerecord", ">= 2.3.3")

  # If your tests use any gems, include them here
  s.add_development_dependency("rake",         "~> 0.8.7")
  s.add_development_dependency("sqlite3-ruby", "~> 1.3.1")
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
