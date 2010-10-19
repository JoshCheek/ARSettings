module ARSettings
  
  # create the settings class
  def self.settings_class=(classname)
    theclass = Class.new(ActiveRecord::Base) do
      extend SettingsClass_ClassMethods
      reset
    end
    Object.const_set classname , theclass    
  end
  
  
  
  
  
  module SettingsClass_ClassMethods
    
    def reset
      (@settings||{}).each do |meth,value|
        (class << self; self; end).send :remove_method  , meth
      end
      @settings = Hash.new
      @default = nil
    end
    
    def setting?(setting)
      @settings.has_key? setting
    end
    
    def add_setting(setting)
      (class << self; self; end).send :define_method , setting do
        @settings[setting]
      end
      @settings[setting] = default
    end
    
    def default
      @default
    end
    
    def default=(new_default)
      @default = new_default
    end
  end
  
end

