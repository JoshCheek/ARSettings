module ARSettings
  module HasSettings
    
    def has_setting( name , inner_options={} , &block )
      @arsettings_package ||= ARSettings.default_class.package(self)
      instance = inner_options.delete :instance
      package = @arsettings_package
      package.add name , inner_options , &block
      definitions = lambda do |*args|
        define_method name        do       package.send name              end # getter
        define_method "#{name}="  do |arg| package.send "#{name}=" , arg  end # setter
        define_method "#{name}?"  do       package.send "#{name}?"        end # boolean-getter
      end
      (class << self ; self ; end).instance_eval(&definitions)
      definitions.call if instance
    end
    
  end
end