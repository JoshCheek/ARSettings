module ARSettings
  module SettingsClass_ClassMethods
    
    def reset_all
      Scoped.instances(self).each { |name,scope| scope.reset }
    end
    
    def scope(scope)
      Scoped.instance self , scope
    end
    
    def add_setting( name , options={} , &proc )
      options = name if name.is_a? Hash
      if options[:scope]
        scope options[:scope]
      else
        scope self
      end.add_setting( name , options , &proc )
    end
     
    def method_missing(name,*args)
      if name =~ /\A[A-Z]/
        const_get name , *args
      elsif name.to_s !~ /=$/ || ( name.to_s =~ /=$/ && args.size == 1 )
        scope(self).send name , *args
        # raise self::NoSuchSettingError.new("There is no setting named #{name.to_s.chomp '='}")
      else
        super
      end
    end
    
    def default
      scope(self).default
    end

  private
  
    def load_from_db
      reset_all
      all.each { |instance| add_setting :record => instance , :scope => instance.scope }
    end

  end
end



# PASSTHROUGH = lambda { |val| val }
# 
# def reset
#   (@settings||{}).each do |name,instance| 
#     remove_setter(name)
#     remove_getter(name)
#     instance.destroy
#   end
#   @settings = Hash.new
#   @default = self::DEFAULT
# end
# 
# def setting?(name)
#   @settings.has_key? name
# end
# 
# def default
#   @default
# end
# 
# def default=(new_default)
#   @default = new_default
# end
# 
# def metaclass
#   class << self
#     self
#   end
# end
# 
# def define_method( name , &body )
#   metaclass.send :define_method , name , &body
# end
# 
# def remove_method(name)
#   metaclass.send :remove_method , "#{setting}="
# end
# 
# def add_setter(name)
#   define_method "#{name}=" do |value|
#     @settings[name].value = @settings[name].postprocessing.call(value)
#   end
# end
# 
# def add_getter(name)
#   define_method(name) { @settings[name].value }
# end
# 
# def remove_setter(name)
#   metaclass.send :remove_method , "#{name}="
# end
# 
# def remove_getter(name)
#   metaclass.send :remove_method , name
# end
# 
# def settings
#   @settings.keys
# end
# 
# def settings_with_values
#   @settings.map { |name,instance| [name,instance.value] }
# end
# 
# 
# def current_scope
#   @current_scope ||= self.to_s.to_sym
# end
# 
