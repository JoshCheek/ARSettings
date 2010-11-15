module ARSettings
  module HasSettings
    
    def has_setting( name , inner_options={} , &block )
      @arsettings_package ||= ARSettings.default_class.package(self)
      instance = inner_options.delete :instance
      package = @arsettings_package
      package.add name , inner_options , &block
      getter = name
      setter = "#{name}="
      boolean_getter = "#{name}?"
      (class << self ; self ; end).instance_eval do
        define_method getter          do       package.send getter          end
        define_method setter          do |arg| package.send setter , arg    end
        define_method boolean_getter  do       package.send boolean_getter  end
      end
      if instance
        define_method getter          do       package.send getter          end
        define_method boolean_getter  do       package.send boolean_getter  end
        define_method setter          do |arg| package.send setter , arg    end
      end
    end
    
  end
end