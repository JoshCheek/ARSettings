module ARSettings
module SettingsClass
module ClassMethods
    
  def reset_all # :nodoc:
    Packaged.instances(self).each { |name,package| package.reset }
  end

  # get a Package (aka namespace or scope or group)
  # to package settings together with
  # 
  # email_settings = Settings.package :email
  #
  # email_settings.add :enabled , :default => false
  # 
  # ProfileSettings = Settings.package :profile_settings
  #
  # ProfileSettings.add :enabled , :default => true
  def package(name)
    Packaged.instance self , name
  end

  # add a setting to the settings class, it will be packaged under the settings class itself
  #
  #--
  # FIXME: Document the options and proc
  def add( name , options={} , &proc )
    options = name if name.is_a? Hash
    if options[:package]
      package options.delete(:package)
    else
      package self
    end.add( name , options , &proc )
  end
  
  alias :has_setting :add
 
  private

  def method_missing(name,*args) # :nodoc:
    if name =~ /\A[A-Z]/
      const_get name , *args
    elsif name.to_s !~ /=$/ || ( name.to_s =~ /=$/ && args.size == 1 )
      package(self).send name , *args
    else
      super
    end
  end

  def load_from_db # :nodoc:
    reset_all
    all.each { |instance| add :record => instance , :package => instance.package }
  end

end
end
end
