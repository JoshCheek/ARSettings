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
    end
    
    def setting?(setting)
      @settings[setting]
    end
    
    def add_setting(setting)
      (class << self; self; end).send :define_method , setting do
        @settings[setting]
      end
      @settings[setting] = true
    end
    
  end
  
end

