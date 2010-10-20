module ARSettings
    
  module SettingsClass_ClassMethods
    
    PASSTHROUGH = lambda { |val| val }
    
    def reset
      (@settings||{}).each do |name,instance| 
        remove_setter(name)
        remove_getter(name)
        instance.destroy
      end
      @settings = Hash.new
      @default = self::DEFAULT
    end
    
    def load_from_db
      raise "this should only be called when initializing" if defined?(@settings)
      reset
      new_settings = Hash.new
      all.each do |instance|
        name = instance.name.intern
        new_settings[name] = instance
        add_setter name
        add_getter name
      end
      @settings = new_settings
    end
    
    def setting?(name)
      @settings.has_key? name
    end
    
    def add_setting( name , options={} , &proc )
      name = name.intern
      raise self::InvalidNameError.new("#{name} is #{name.length}, but MAX_CHARS is set to #{self::MAX_CHARS}") if name.length > self::MAX_CHARS
      if setting? name
        @settings[name].volatile        =  options[:volatile]  if options.has_key? :volatile
        @settings[name].postprocessing  =  proc                if proc
      else
        add_setter(name)
        add_getter(name)
        @settings[name] = new :name => name.to_s , :postprocessing => proc || PASSTHROUGH , :volatile => !!options.fetch(:volatile,self::VOLATILIE_DEFAULT)
        send "#{name}=" , options.fetch(:default,default)
      end
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
    
    def settings
      @settings.keys
    end
    
    def settings_with_values
      @settings.map { |name,instance| [name,instance.value] }
    end
    
    def method_missing(name,*args)
      if name =~ /\A[A-Z]/
        const_get name , *args
      elsif name.to_s !~ /=$/ || ( name.to_s =~ /=$/ && args.size == 1 )
        raise self::NoSuchSettingError.new("There is no setting named #{name.to_s.chomp '='}")
      else
        super
      end
    end
    
    def scope(scope)
      raise self::InvalidScopeError.new("#{scope.inspect} is not valid, should be a String, Symbol, or Class") unless String === scope || Symbol === scope || Class === scope
      self::Scoped.new scope , self
    end
    
    def current_scope
      @current_scope ||= self.to_s.to_sym
    end
    
  end
  
end

