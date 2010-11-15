require 'yaml'

manifest = %w(
  arsettings
  settings_class/class_methods
  settings_class/instance_methods
  packaged
  has_settings
)

manifest.each do |filename|
  require File.dirname(__FILE__) << "/arsettings/#{filename}"
end



# placing this here because otherwise it violates packaging standard
class ActiveRecord::Base
  
  def self.inherited_with_settings(subclass)
    inherited_without_settings subclass
    subclass.extend ARSettings::HasSettings
  end
  
  class << self
    alias_method_chain :inherited, :settings
  end
  
end