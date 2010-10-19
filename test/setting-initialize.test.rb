require File.dirname(__FILE__) + '/_helper'

class InitializingSettingsClasses < Test::Unit::TestCase
  
  # can't lazy load so that error only shows up if you try to use it
  # because we need to read the table immediately to load propagated settings
  verify 'raises error if db does not support the class' do
    assert_raises(ActiveRecord::StatementInvalid) { ARSettings.create_settings_class 'NotInTheDatabase' }
  end
  
  verify 'raises error if the constant already exists' do
    assert_nothing_raised { ARSettings.create_settings_class 'Setting2' }
    assert_raises(ARSettings::AlreadyDefinedError) { ARSettings.create_settings_class 'Setting2' }
  end
  
  verify 'can set default when initializing' do
    ARSettings.create_settings_class 'Setting3' , :default => 123
    assert_equal 123 , Setting3.default
    Setting3.reset
    assert_equal 123 , Setting3.default
    Setting3.default = 456
    assert_equal 456 , Setting3.default
    Setting3.reset
    assert_equal 123 , Setting3.default
  end
  
  verify 'loads up values previously stored in the db' do
    $sql_executor.silent_execute "insert into predefined_values (name,value) values ('predefined_value','#{ARSettings.serialize(12)}')"
    ARSettings.create_settings_class :PredefinedValues
    # make sure it loads the value
    assert_equal 1 , PredefinedValues.count
    assert PredefinedValues.setting?(:predefined_value)
    assert_equal 12 , PredefinedValues.predefined_value
    # make sure it recognizes exclusiveness of the setting
    assert_raises(ARSettings::AlreadyDefinedError) { PredefinedValues.add_setting :predefined_value }
  end
    
end
