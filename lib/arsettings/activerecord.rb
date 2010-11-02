class ActiveRecord::Base
  
  def self.has_setting( name , options=Hash.new , &block)
    raise NoDefaultPackageError.new("No default settings class is set (make sure you have already invoked create_settings_class)") unless ARSettings.default_class
    ARSettings.validate_options options , :default , :volatile , :instance
    package         =  ARSettings.default_class.package(self)
    getter          =  name
    setter          =  "#{name}="
    boolean_getter  =  "#{name}?"
    (class << self ; self ; end).instance_eval do
      define_method getter          do       package.send getter          end
      define_method boolean_getter  do       package.send boolean_getter  end
      define_method setter          do |arg| package.send setter , arg    end
    end
    if options.delete :instance
      define_method getter          do       package.send getter          end
      define_method boolean_getter  do       package.send boolean_getter  end
      define_method setter          do |arg| package.send setter , arg    end
    end
    package.add name , options , &block
  end
  
end