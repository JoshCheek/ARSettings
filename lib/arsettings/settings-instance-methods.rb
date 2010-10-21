module ARSettings
    
  module SettingsClass_InstanceMethods

    # unfortunately, can't serialize a proc. I tried both yaml and marshal
    # so will have to keep it in memory and just be sure to set it each time app loads
    attr_accessor :postprocessing

    
    def value=(new_value)
      @deserialized_value = new_value
      @value_is_deserialized = true
      super ARSettings.serialize(new_value)
      save
    end
    
    def value
      if @value_is_deserialized && !volatile?
        @deserialized_value
      else
        reload
        @value_is_deserialized = true
        @deserialized_value = ARSettings.deserialize(super)
        @deserialized_value = postprocessing[@deserialized_value] if volatile
        @deserialized_value
      end
    end
        
    def volatile=(value)
      super
      save
    end
    
  end
  
end
