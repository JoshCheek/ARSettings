class ActiveRecord::Base
  
  def self.inherited_with_settings(subclass)
    inherited_without_settings subclass
    subclass.extend ARSettings::HasSettings
  end
  
  class << self
    alias_method_chain :inherited, :settings
  end
  
end