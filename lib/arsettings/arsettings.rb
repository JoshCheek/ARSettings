module ARSettings
  
  AlreadyDefinedError       = Class.new(Exception)
  NoSuchSettingError        = Class.new(Exception)
  InvalidNameError          = Class.new(Exception)
  InvalidPackageError       = Class.new(Exception)
  InvalidOptionError        = Class.new(Exception)
  NoDefaultPackageError     = Class.new(Exception)
  UninitializedSettingError = Class.new(Exception)
  
  # create the settings class
  def self.create_settings_class( classname , options=Hash.new )
    raise AlreadyDefinedError.new("you are trying to define the settings class #{classname}, but it already exists") if Object.constants.map { |c| c.to_s }.include?(classname.to_s)
    validate_options options , :volatile , :max_chars
    Object.const_set classname , Class.new(ActiveRecord::Base)
    klass = Object.const_get(classname).class_eval do
      extend  SettingsClass_ClassMethods
      include SettingsClass_InstanceMethods
      const_set :MAX_CHARS           , options.fetch( :max_chars , 30    )
      const_set :VOLATILIE_DEFAULT   , options.fetch( :volatile  , false )
      send :load_from_db
      self
    end
    @default_class ||= klass
    klass
  end
  
  class << self
    attr_accessor :default_class
  end
  
  # can be used to put settings on any object
  def self.on( object , options = Hash.new )
    settings_class = options.fetch :settings_class , default_class
    raise NoDefaultPackageError.new("You did not specify a settings class, and no default is set (make sure you have already invoked create_settings_class)") unless settings_class
    validate_options options , :settings_class
    object.instance_variable_set( '@arsettings_package' , settings_class.package(object) )
    (class << object ; self ; end).send :include , HasSettings
  end
  
  def self.serialize(data) # :nodoc:
    YAML::dump(data)
  end
  
  def self.deserialize(data) # :nodoc:
    YAML::load(data)
  end
  
  def self.validate_options(options,*valid_options) # :nodoc:
    options.each do |option,value|
      unless valid_options.include? option
        raise ARSettings::InvalidOptionError.new "#{option.inspect} is not a valid option, because it is not in #{valid_options.inspect}"
      end
    end
  end
    
end

