module ARSettings
  module SettingsClass_ClassMethods
    
    def reset_all
      Scoped.instances(self).each { |name,scope| scope.reset }
    end
    
    def scope(scope)
      Scoped.instance self , scope
    end
    
    def add( name , options={} , &proc )
      options = name if name.is_a? Hash
      if options[:scope]
        scope options[:scope]
      else
        scope self
      end.add( name , options , &proc )
    end
     
    def method_missing(name,*args)
      if name =~ /\A[A-Z]/
        const_get name , *args
      elsif name.to_s !~ /=$/ || ( name.to_s =~ /=$/ && args.size == 1 )
        scope(self).send name , *args
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
      all.each { |instance| add :record => instance , :scope => instance.scope }
    end

  end
end
