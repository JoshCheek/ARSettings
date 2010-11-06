require File.dirname(__FILE__) + '/helper'
require File.dirname(__FILE__) + '/../lib/arsettings'

# tell it to create us a settings class named Settings
# this means you must have a table in your db named 'settings'
ARSettings.create_settings_class 'Settings'


# ========== Use On An ActiveRecord Class  ==========
class User < ActiveRecord::Base
  has_setting(:site_admin) { |user| user.name }
  has_setting :delete_account_after , :instance => true , :default => 365   # days
end

User.create! :name => 'the admin' 
User.site_admin = User.first
User.site_admin                 # => "the admin"
User.new.delete_account_after   # => 365


# ========== Use On Any Class  ==========
class Water
  ARSettings.on self
  has_setting :hydrogen , :default => 1
  has_setting :oxygen   , :default => 2
  has_setting :state    , :default => :liquid , :instance => true
end

Water.hydrogen # => 1
Water.oxygen   # => 2
Water.new.state # => :liquid


# ==========  Generic Settings  ==========
Settings.add :domain , :default => 'localhost:3000'
Settings.domain # => "localhost:3000"

Settings.domain = 'localhost:9292'
Settings.domain # => "localhost:9292"


# ==========  Namespace Settings With Packages  ==========
EmailSettings = Settings.package :email
EmailSettings.add :enabled

# what happens if you don't initialize?
begin 
  EmailSettings.enabled? # => 
rescue ARSettings::UninitializedSettingError => e
  e # => #<ARSettings::UninitializedSettingError: email#enabled has not been initialized.>
end

# initialize, and show that boolean methods translate object/nil to true/false
EmailSettings.enabled = 'yes'
EmailSettings.enabled? # => true

EmailSettings.enabled = nil
EmailSettings.enabled? # => false

# can access the package still via the package method
Settings.package(:email) == EmailSettings   # => true
Settings.package(:email).enabled?           # => false
