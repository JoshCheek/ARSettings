module ARSettings
  
  AlreadyDefinedError = Class.new(Exception)
  NoSuchSettingError  = Class.new(Exception)
  InvalidNameError    = Class.new(Exception)
  InvalidScopeError   = Class.new(Exception)
  
  # create the settings class
  def self.create_settings_class( classname , options=Hash.new )
    raise AlreadyDefinedError.new("you are trying to define the settings class #{classname}, but it already exists") if Object.constants.map { |c| c.to_s }.include?(classname.to_s)
    Object.const_set classname , Class.new(ActiveRecord::Base)
    Object.const_get(classname).class_eval do
      extend  SettingsClass_ClassMethods
      include SettingsClass_InstanceMethods
      const_set :DEFAULT             , options.fetch( :default   , nil   )
      const_set :MAX_CHARS           , options.fetch( :max_chars , 30    )
      const_set :VOLATILIE_DEFAULT   , options.fetch( :volatile  , false )
      send :load_from_db
      self
    end
  end
  
  def self.serialize(data)
    YAML::dump(data)
  end
  
  def self.deserialize(data)
    YAML::load(data)
  end
  
end

