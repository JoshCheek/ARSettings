require File.dirname(__FILE__) + '/helper'
require File.dirname(__FILE__) + '/../lib/arsettings'

# tell it to create us a settings class named Settings
# this means you must have a table in your db named 'settings'
ARSettings.create_settings_class 'Settings'


# you can package settings together under a namespace
EmailSettings = Settings.package :email

# you can add settings with has_setting for consistency with other places that can have settings
# or you can use add for brevity
Settings.add :enabled
EmailSettings.has_setting :enabled

# initialize, and show that boolean methods translate object/nil to true/false
EmailSettings.enabled = 'yes'
EmailSettings.enabled? # => true

EmailSettings.enabled = nil
EmailSettings.enabled? # => false

# can access the package still via the ::package method
Settings.package(:email) == EmailSettings   # => true
Settings.package(:email).enabled?           # => false


# Settings and EmailSettings are under different packages (namespaces)
# so they do not conflict with eachother's values
Settings.enabled = true
Settings.enabled?      # => true
EmailSettings.enabled? # => false
