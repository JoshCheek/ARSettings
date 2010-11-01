module ARSettings
  module SettingsClass_ClassMethods
    
    def reset_all
      Packaged.instances(self).each { |name,package| package.reset }
    end
    
    def package(package)
      Packaged.instance self , package
    end
    
    def add( name , options={} , &proc )
      options = name if name.is_a? Hash
      if options[:package]
        package options[:package]
      else
        package self
      end.add( name , options , &proc )
    end
     
    def method_missing(name,*args)
      if name =~ /\A[A-Z]/
        const_get name , *args
      elsif name.to_s !~ /=$/ || ( name.to_s =~ /=$/ && args.size == 1 )
        package(self).send name , *args
      else
        super
      end
    end
    
  private
  
    def load_from_db
      reset_all
      all.each { |instance| add :record => instance , :package => instance.package }
    end

  end
end
