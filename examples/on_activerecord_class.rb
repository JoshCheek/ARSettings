require File.dirname(__FILE__) + '/helper'
require File.dirname(__FILE__) + '/../lib/arsettings'

# tell it to create us a settings class named Settings
# this means you must have a table in your db named 'settings'
ARSettings.create_settings_class 'Settings'

class User < ActiveRecord::Base
  has_setting(:site_admin) { |user| user.name }
  has_setting :delete_account_after , :instance => true , :default => 365   # days
end

User.create! :name => 'the admin'
User.site_admin = User.first    

# block converted the user to its name
User.site_admin                 # => "the admin"

# can access the setting on the instance, because we passed :instance => true
User.new.delete_account_after   # => 365
