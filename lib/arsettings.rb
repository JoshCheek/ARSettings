require 'yaml'

manifest = %w(
  arsettings
  settings_class/class_methods
  settings_class/instance_methods
  packaged
  activerecord
  has_settings
)

manifest.each do |filename|
  require File.dirname(__FILE__) << "/arsettings/#{filename}"
end