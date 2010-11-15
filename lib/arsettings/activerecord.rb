class ActiveRecord::Base
  
  old_inherited = method :inherited
  
  (class << self ; self ; end).instance_eval do
    define_method :inherited do |subclass|
      old_inherited.call subclass
      subclass.extend ARSettings::HasSettings
    end
  end
  
end