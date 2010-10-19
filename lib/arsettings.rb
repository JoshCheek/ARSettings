require 'yaml'

manifest = %w(
  arsettings
  class-methods
  instance-methods
)

manifest.each do |filename|
  require File.dirname(__FILE__) << "/arsettings/#{filename}"
end