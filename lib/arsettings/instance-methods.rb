module ARSettings
    
  module SettingsClass_InstanceMethods
    
    def value=(new_value)
      @deserialized_value = new_value
      @value_is_deserialized = true
      super ARSettings.serialize(new_value)
      save
    end
    
    def value
      if @value_is_deserialized
        @deserialized_value
      else
        @value_is_deserialized = true
        @deserialized_value = ARSettings.deserialize(super)
      end
    end
    
    # unfortunately, can't serialize a proc. I tried both yaml and marshal
    # so will have to keep it in memory and just be sure to set it each time app loads
    attr_accessor :postprocessing
    
  end
  
end

