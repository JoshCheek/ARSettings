class ActiveRecord::Base
  
  def self.has_setting( name , options=Hash.new , &block)
    raise NoDefaultScopeError.new("No default settings class is set (make sure you have already invoked create_settings_class)") unless ARSettings.default_class
    scope = ARSettings.default_class.scope(self)
    scope.add name , options , &block
    getter = name
    setter = "#{name}="
    (class << self ; self ; end).instance_eval do
      define_method getter do       scope.send getter       end
      define_method setter do |arg| scope.send setter , arg end
    end
    define_method getter do       scope.send getter       end
    define_method setter do |arg| scope.send setter , arg end    
  end
  
end