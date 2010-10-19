require 'yaml'

manifest = %w(
  arsettings
  settings-class-methods
  settings-instance-methods
  activerecord
)

manifest.each do |filename|
  require File.dirname(__FILE__) << "/arsettings/#{filename}"
end