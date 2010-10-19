module ARSettings
  
  AlreadyDefinedError = Class.new(Exception)
  
  # create the settings class
  def self.settings_class=(classname)
    theclass = Class.new(ActiveRecord::Base) do
      extend SettingsClass_ClassMethods
      const_set :AlreadyDefinedError , ARSettings::AlreadyDefinedError
      reset
    end
    Object.const_set classname , theclass    
  end
  
  
  
  
  
  module SettingsClass_ClassMethods
    
    PASSTHROUGH = lambda { |val| val }
    
    def reset
      (@settings||{}).each { |name,atrb| remove_setter(name) ; remove_getter(name) }
      @settings = Hash.new
      @default = nil
    end
    
    def setting?(name)
      @settings.has_key? name
    end
    
    def add_setting( name , the_default=self.default , &proc )
      raise AlreadyDefinedError.new("#{name} has already been added as a setting") if setting? name
      add_setter(name)
      add_getter(name)
      @settings[name] = { :postprocessing => proc || PASSTHROUGH }
      send "#{name}=" , the_default
    end
    
    def default
      @default
    end
    
    def default=(new_default)
      @default = new_default
    end
    
    def metaclass
      class << self
        self
      end
    end
    
    def define_method( name , &body )
      metaclass.send :define_method , name , &body
    end
    
    def remove_method(name)
      metaclass.send :remove_method , "#{setting}="
    end
    
    def add_setter(name)
      define_method "#{name}=" do |value|
        @settings[name][:value] = @settings[name][:postprocessing][value]
      end
    end
    
    def add_getter(name)
      define_method(name) { @settings[name][:value] }
    end
    
    def remove_setter(name)
      metaclass.send :remove_method , "#{name}="
    end
    
    def remove_getter(name)
      metaclass.send :remove_method , name
    end
    
  end
  
end

