module ARSettings
  
  AlreadyDefinedError = Class.new(Exception)
  
  # create the settings class
  def self.create_settings_class( classname , options=Hash.new )
    raise AlreadyDefinedError.new("you are trying to define the settings class #{classname}, but it already exists") if Object.constants.map { |c| c.to_s }.include?(classname.to_s)
    
    theclass = Class.new(ActiveRecord::Base) do
      extend  SettingsClass_ClassMethods
      include SettingsClass_InstanceMethods
      const_set :AlreadyDefinedError , ARSettings::AlreadyDefinedError
      const_set :DEFAULT , options[:default]
      reset
    end
    Object.const_set classname , theclass    
  end
  
end
