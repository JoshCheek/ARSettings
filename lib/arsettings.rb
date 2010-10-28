require 'yaml'

manifest = %w(
  arsettings
  settings_class_methods
  settings_instance_methods
  packaged
  activerecord
)

manifest.each do |filename|
  require File.dirname(__FILE__) << "/arsettings/#{filename}"
end