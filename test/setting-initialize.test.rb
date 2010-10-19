require File.dirname(__FILE__) + '/_helper'

class CanChooseNameOfSettingClass < Test::Unit::TestCase
  
  # verify 'raises error if db does not support the class' do
  #   assert_nothing_raised { ARSettings.create_settings_class 'NotInTheDatabase' }
  #   assert_raises(Setting::NoDatabaseError) { NotInTheDatabase.add_setting :abc }
  # end
  
  verify 'raises error if the constant already exists' do
    assert_nothing_raised { ARSettings.create_settings_class 'Setting2' }
    assert_raises(ARSettings::AlreadyDefinedError) { ARSettings.create_settings_class 'Setting2' }
  end
  
  # verify 'can set default when initializing' do
  #   ARSettings.create_settings_class 'Setting3' , :default => 123
  #   assert_equal 123 , Setting3.default
  #   ARSettings.reset
  #   assert_equal 123 , Setting3.default
  # end  
    
end
