%w(
  arsettings
  class-methods
  instance-methods
).each do |filename|
  require File.dirname(__FILE__) << "/arsettings/#{filename}"
end