module ARSettings 
  class Packaged
    
    InvalidSettingsClassError = Class.new Exception
    PASSTHROUGH = lambda { |val| val } # :nodoc:
    
    attr_reader :package , :settings_class
    
    private_class_method :new
        
    def self.instance(settings_class,package) # :nodoc:
      validate(settings_class,package)
      package = normalize package
      @instances ||= Hash.new
      @instances[settings_class] ||= Hash.new
      @instances[settings_class][package] ||= new(settings_class,package)
    end
    
    def self.has_instance?(settings_class,package) # :nodoc:
      @instances && @instances[settings_class] && @instances[settings_class][normalize(package)]
    end
    
    def self.validate(settings_class,package) # :nodoc:
      validate_package(package)
      validate_settings_class(settings_class)
    end
    
    def self.validate_package(package) # :nodoc:
      raise ARSettings::InvalidPackageError.new("#{package.inspect} should be a String/Symbol/Class") unless 
          String === package || Symbol === package || Class === package
    end
    
    def self.validate_settings_class(settings_class) # :nodoc:
      raise InvalidSettingsClassError.new("#{settings_class.inspect} should be a class created by the create_settings_class method") unless 
          Class === settings_class && settings_class.superclass == ActiveRecord::Base && SettingsClass::ClassMethods === settings_class
    end
   
   
    # instance methods
    
    def initialize(settings_class,package) # :nodoc:
      @package , @settings_class , @settings = package.to_s.to_sym , settings_class , Hash.new
    end    
    
    # Destroy all of this package's settings *WARNING* This will wipe them out of the database
    def reset
      (@settings||{}).each do |name,instance| 
        remove_setter(name)
        remove_getter(name)
        remove_boolean_getter(name)
        instance.destroy
      end
      @settings = Hash.new
    end
    
    def add( name , options={} , &proc )
      return(add_from_instance name[:record]) if name.is_a? Hash # internal use only
      ARSettings.validate_options options , :volatile , :default
      name = name.to_sym
      validate_name(name)
      if setting? name
        @settings[name].volatile        =  options[:volatile]  if options.has_key? :volatile
        @settings[name].postprocessing  =  proc                if proc
      else
        add_setter(name)
        add_getter(name)
        add_boolean_getter(name)
        @settings[name] = settings_class.new :name => name.to_s , :postprocessing => proc || PASSTHROUGH , :volatile => !!options.fetch(:volatile,settings_class::VOLATILIE_DEFAULT) , :package => package
        send "#{name}=" , options[:default] if options.has_key?(:default)
      end
      self
    end
    
    alias :has_setting :add

    def setting?(name)
      @settings.has_key? name
    end
        
    def settings
      @settings.keys
    end
    
    def settings_with_values
      @settings.map { |name,instance| [name,instance.value] }
    end
    
  private
  
    def self.instances(settings_class) # :nodoc:
      @instances ||= Hash.new
      @instances[settings_class] || Hash.new
    end
  
    def self.normalize(package) # :nodoc:
      return package if Symbol === package
      package.to_s.to_sym
    end

    def validate_name(name) # :nodoc:
      raise ARSettings::InvalidNameError.new("#{name} is #{name.to_s.size}, but MAX_CHARS is set to #{settings_class::MAX_CHARS}") if name.to_s.length > settings_class::MAX_CHARS
      regex = /\A[a-z_][a-zA-Z_]*\Z/m
      raise ARSettings::InvalidNameError.new("#{name.inspect} is not a valid settings name, because it is not a valid method name since it does not match #{regex.inspect}") if name.to_s !~ regex
    end
  
    def metaclass # :nodoc:
      class << self
        self
      end
    end
  
    def define_method( name , &body ) # :nodoc:
      metaclass.send :define_method , name , &body
    end
  
    def remove_method(name) # :nodoc:
      metaclass.send :remove_method , name
    end

    def add_setter(name) # :nodoc:
      define_method "#{name}=" do |value|
        @settings[name].value = @settings[name].postprocessing.call(value)
      end
    end
  
    def add_getter(name) # :nodoc:
      define_method(name) { @settings[name].value }
    end
  
    def add_boolean_getter(name) # :nodoc:
      define_method("#{name}?") { !!@settings[name].value }
    end

    def remove_setter(name) # :nodoc:
      remove_method "#{name}="
    end
  
    def remove_getter(name) # :nodoc:
      remove_method name
    end
  
    def remove_boolean_getter(name) # :nodoc:
      remove_method "#{name}?"
    end
  
    def method_missing(name,*args) # :nodoc:
      name_to_s = name.to_s
      if name_to_s =~ /\A[A-Z]/
        settings_class.const_get name , *args
      elsif name_to_s !~ /=$/ || ( name_to_s =~ /=$/ && args.size == 1 )
        raise ARSettings::NoSuchSettingError.new("There is no setting named #{name_to_s.chomp '='}")
      else
        super
      end
    end

    def add_from_instance(record) # :nodoc:
      record.postprocessing = PASSTHROUGH
      name = record.name.to_sym
      validate_name(name)
      add_setter(name)
      add_getter(name)
      add_boolean_getter(name)
      @settings[name] = record
    end
    
  end
end

