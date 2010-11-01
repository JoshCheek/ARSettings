require File.dirname(__FILE__) + '/db'
require File.dirname(__FILE__) + '/../lib/arsettings'

# tell it to create us a settings class named Settings
ARSettings.create_settings_class 'Settings'

# ==========  For Use On An ActiveRecord Class  ==========
class User < ActiveRecord::Base
  has_setting(:site_admin) { |user| user.id }
  has_setting :delete_acct_after , :default => 365   # days
end

User.create! :name => 'the admin' 
# User.site_admin = User.first
# User.site_admin # => 


User.site_admin         # => 
User.site_admin = 100   
# ~> -:26: syntax error, unexpected $end, expecting ')'
