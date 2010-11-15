require File.dirname(__FILE__) + '/helper' # !> method redefined; discarding old warn
require File.dirname(__FILE__) + '/../lib/arsettings'

# tell it to create us a settings class named Settings
# this means you must have a table in your db named 'settings'
ARSettings.create_settings_class 'Settings'


# to namespace the settings, use the package method
# I know its a crappy name, but scope, namespace, and group
# are all already taken by ActiveRecord -.-

EmailSettings = Settings.package :email
EmailSettings.add :enabled

# initialize, and show that boolean methods translate object/nil to true/false
EmailSettings.enabled = 'yes'
EmailSettings.enabled? # => true

EmailSettings.enabled = nil
EmailSettings.enabled? # => false

# can access the package still via the ::package method
Settings.package(:email) == EmailSettings   # => true
Settings.package(:email).enabled?           # => false
