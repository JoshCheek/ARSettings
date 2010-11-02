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
    valid_options = [:settings_class]
    options.each do |key,value|
      raise ARSettings::InvalidOptionError.new("#{key.inspect} is not a valid option, because it is not in #{valid_options.inspect}") unless valid_options.include? key
    end
    (class << object ; self ; end).send :define_method , :has_setting do |name,options={},&block|
      package = settings_class.package(object)
      package.add name , options , &block
      (class << self ; self ; end).instance_eval do
        getter = name
        setter = "#{name}="
        boolean_getter = "#{name}?"
        define_method getter          do       package.send getter          end
        define_method setter          do |arg| package.send setter , arg    end
        define_method boolean_getter  do       package.send boolean_getter  end
      end
    end
  end
  
  def self.serialize(data)
    YAML::dump(data)
  end
  
  def self.deserialize(data)
    YAML::load(data)
  end
  
end

