class ActiveRecord::Base
  
  def self.has_setting( name , options=Hash.new , &block)
    raise NoDefaultPackageError.new("No default settings class is set (make sure you have already invoked create_settings_class)") unless ARSettings.default_class
    valid_options = [:default,:volatile,:instance]
    options.each do |key,value|
      raise ARSettings::InvalidOptionError.new("#{key.inspect} is not a valid option, because it is not in #{valid_options.inspect}") unless valid_options.include? key
    end
    package = ARSettings.default_class.package(self)
    package.add name , options , &block
    getter = name
    setter = "#{name}="
    boolean_getter = "#{name}?"
    (class << self ; self ; end).instance_eval do
      define_method getter          do       package.send getter          end
      define_method boolean_getter  do       package.send boolean_getter  end
      define_method setter          do |arg| package.send setter , arg    end
    end
    if options[:instance]
      define_method getter          do       package.send getter          end
      define_method boolean_getter  do       package.send boolean_getter  end
      define_method setter          do |arg| package.send setter , arg    end
    end
  end
  
end