require File.dirname(__FILE__) + '/helper'
require File.dirname(__FILE__) + '/../lib/arsettings'

# tell it to create us a settings class named Settings
# this means you must have a table in your db named 'settings'
ARSettings.create_settings_class 'Settings'

# add and change a setting
Settings.add :domain , :default => 'localhost:3000'
Settings.domain                       # => "localhost:3000"
Settings.domain = 'localhost:9292'
Settings.domain                       # => "localhost:9292"


# what if the value is never initialized? (ie first use with no default)
Settings.add :port
begin 
  Settings.port
rescue ARSettings::UninitializedSettingError
  $! # => #<ARSettings::UninitializedSettingError: Settings#port has not been initialized.>
end
Settings.port = 3000
Settings.port         # => 3000
