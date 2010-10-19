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
    
    PASSTHROUGH = lambda { |val| val }
    
    def reset
      (@settings||{}).each do |setting,attributes|
        (class << self; self; end).send :remove_method  , setting
        (class << self; self; end).send :remove_method  , "#{setting}="
      end
      @settings = Hash.new
      @default = nil
    end
    
    def setting?(setting)
      @settings.has_key? setting
    end
    
    def add_setting( setting , the_default=self.default , &proc )
      (class << self; self; end).send :define_method , setting do
        @settings[setting][:value]
      end
      (class << self; self; end).send :define_method , "#{setting}=" do |value|
        @settings[setting][:value] = @settings[setting][:postprocessing][value]
      end
      @settings[setting] = Hash.new
      @settings[setting][:postprocessing] = proc || PASSTHROUGH
      send "#{setting}=" , the_default
    end
    
    def default
      @default
    end
    
    def default=(new_default)
      @default = new_default
    end
    
  end
  
end

