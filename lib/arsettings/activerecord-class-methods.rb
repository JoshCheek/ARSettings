module ARSettings    
  module ActiveRecord_ClassMethods
    
    def add( name , options=Hash.new )
      settings_class
    end
    
    def settings_class=(klass)
      @settings_class = klass
    end
    
    def settings_class
      @settings_class
    end
    
  end  
end
