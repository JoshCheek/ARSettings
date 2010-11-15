require File.dirname(__FILE__) + '/helper'
require File.dirname(__FILE__) + '/../lib/arsettings'

# tell it to create us a settings class named Settings
# this means you must have a table in your db named 'settings'
ARSettings.create_settings_class 'Settings'


class Water
  ARSettings.on self
  has_setting :hydrogen , :default => 1
  has_setting :oxygen   , :default => 2
  has_setting :state    , :default => :liquid , :instance => true
end

Water.hydrogen  # => 1
Water.oxygen    # => 2
Water.new.state # => :liquid
