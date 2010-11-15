class ActiveRecord::Base
  
  old_inherited = method :inherited
  (class << self; self; end).send :define_method , :inherited do |subclass|
    old_inherited.call(subclass)
    (class << subclass ; self ; end).send :include , ARSettings::HasSettings
  end
  
end