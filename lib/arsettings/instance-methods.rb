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
    
    def postprocessing=(proc)
      @deserialized_postprocessing = proc
      @postprocessing_is_deserialized = true
      super ARSettings.serialize(proc)
      save
    end
    
    def postprocessing
      if @postprocessing_is_deserialized
        @deserialized_postprocessing
      else
        @postprocessing_is_deserialized = true
        @deserialized_postprocessing = ARSettings.deserialize(super)
      end
    end
    
  end
  
end

