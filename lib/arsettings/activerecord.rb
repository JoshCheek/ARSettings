class ActiveRecord::Base
  
  def self.has_settings( options = {} )
    # options[:settings_class] = Setting unless options.has_key?
    extend ARSettings::ActiveRecord_ClassMethods
    self.settings_class = Setting
  end
  
end