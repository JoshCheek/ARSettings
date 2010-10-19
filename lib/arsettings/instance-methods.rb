module ARSettings
    
  module SettingsClass_InstanceMethods
    
    def value=(new_value)
      @deserialized_value = new_value
      super ARSettings.serialize(new_value)
      save
    end
    
    def value
      if defined?(@deserialized_value) 
        @deserialized_value
      else
        @deserialized_value = ARSettings.deserialize(super)
      end
    end
    
  end
  
end

