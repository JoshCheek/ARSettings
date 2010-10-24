module ARSettings 
  class Scoped
    
    InvalidSettingsClassError = Class.new Exception
    PASSTHROUGH = lambda { |val| val }
    
    attr_reader :scope , :settings_class
    
    private_class_method :new
        
    def self.instance(settings_class,scope)
      validate(settings_class,scope)
      scope = normalize scope
      @instances ||= Hash.new
      @instances[settings_class] ||= Hash.new
      @instances[settings_class][scope] ||= new(settings_class,scope)
    end
    
    def self.has_instance?(settings_class,scope)
      @instances && @instances[settings_class] && @instances[settings_class][normalize scope]
    end
    
    def self.validate(settings_class,scope)
      validate_scope(scope)
      validate_settings_class(settings_class)
    end
    
    def self.validate_scope(scope)
      raise ARSettings::InvalidScopeError.new("#{scope.inspect} should be a String/Symbol/Class") unless 
          String === scope || Symbol === scope || Class === scope
    end
    
    def self.validate_settings_class(settings_class)
      raise InvalidSettingsClassError.new("#{settings_class.inspect} should be a class created by the create_settings_class method") unless 
          Class === settings_class && settings_class.superclass == ActiveRecord::Base && SettingsClass_ClassMethods === settings_class
    end
    
    def self.instances(settings_class)
      @instances ||= Hash.new
      @instances[settings_class] || Hash.new
    end
    
    def self.normalize(scope)
      return scope if Symbol === scope
      scope.to_s.to_sym
    end
   
   
    # instance methods
        
    def initialize(settings_class,scope)
      @scope , @settings_class , @settings = scope.to_s.to_sym , settings_class , Hash.new
    end    
    
    def reset
      (@settings||{}).each do |name,instance| 
        remove_setter(name)
        remove_getter(name)
        instance.destroy
      end
      @settings = Hash.new
      @default = settings_class::DEFAULT
    end
    
    def validate_name(name)
      raise settings_class::InvalidNameError.new("#{name} is #{name.to_s.size}, but MAX_CHARS is set to #{settings_class::MAX_CHARS}") if name.to_s.length > settings_class::MAX_CHARS
      regex = /\A[a-z_][a-zA-Z_]*\Z/m
      raise settings_class::InvalidNameError.new("#{name.inspect} is not a valid settings name, because it is not a valid method name since it does not match #{regex.inspect}") if name !~ regex
    end
    
    def add_setting( name , options={} , &proc )
      return(add_from_instance name[:record]) if name.is_a? Hash # internal use only
      name = name.to_sym
      validate_name(name)
      if setting? name
        @settings[name].volatile        =  options[:volatile]  if options.has_key? :volatile
        @settings[name].postprocessing  =  proc                if proc
        send name
      else
        add_setter(name)
        add_getter(name)
        @settings[name] = settings_class.new :name => name.to_s , :postprocessing => proc || PASSTHROUGH , :volatile => !!options.fetch(:volatile,settings_class::VOLATILIE_DEFAULT) , :scope => scope
        send "#{name}=" , options.fetch(:default,default)
      end
    end

    def setting?(name)
      @settings.has_key? name
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
        @settings[name].value = @settings[name].postprocessing.call(value)
      end
    end
    
    def add_getter(name)
      define_method(name) { @settings[name].value }
    end
    
    def remove_setter(name)
      metaclass.send :remove_method , "#{name}="
    end
    
    def remove_getter(name)
      metaclass.send :remove_method , name
    end
    
    def method_missing(name,*args)
      if name.to_s =~ /\A[A-Z]/
        const_get name , *args
      elsif name.to_s !~ /=$/ || ( name.to_s =~ /=$/ && args.size == 1 )
        raise ARSettings::NoSuchSettingError.new("There is no setting named #{name.to_s.chomp '='}")
      else
        super
      end
    end
    
    def settings
      @settings.keys
    end
    
    def settings_with_values
      @settings.map { |name,instance| [name,instance.value] }
    end

    def default=(default)
      @default = default
    end

    def default
      if defined?(@default)
        @default
      else
        settings_class::DEFAULT
      end
    end
    
  private
  
    def add_from_instance(record)
      record.postprocessing = PASSTHROUGH
      name = record.name.to_sym
      validate_name(name)
      add_setter(name)
      add_getter(name)
      @settings[name.to_sym] = record
      return record.value
    end
    
  end
end

