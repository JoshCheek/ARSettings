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
    PredefinedValues.add_setting :predefined_value , :default => 13
    assert_equal 12 , PredefinedValues.predefined_value
  end
   
  verify 'can specify a volatility default' do
    ARSettings.create_settings_class :VolatileTest    , :volatile => true
    VolatileTest.add_setting :abcd , :default => 1    , :volatile => false
    VolatileTest.add_setting :efgh , :default => 10   , :volatile => true
    VolatileTest.add_setting :ijkl , :default => 100
    assert_equal 1   , VolatileTest.abcd
    assert_equal 10  , VolatileTest.efgh
    assert_equal 100 , VolatileTest.ijkl
    $sql_executor.silent_execute "update volatile_tests set value='#{ARSettings.serialize(2)}' where name='abcd'"
    $sql_executor.silent_execute "update volatile_tests set value='#{ARSettings.serialize(20)}' where name='efgh'"
    $sql_executor.silent_execute "update volatile_tests set value='#{ARSettings.serialize(200)}' where name='ijkl'"
    assert_equal 1   , VolatileTest.abcd
    assert_equal 20  , VolatileTest.efgh
    assert_equal 200 , VolatileTest.ijkl
  end
  
  verify 'create_settings_class should return the class' do
    result = ARSettings.create_settings_class :ThisShouldBeReturned
    assert_equal ThisShouldBeReturned , result
  end
  
  verify 'cannot reload from db' do
    assert_raises(RuntimeError) { Setting.load_from_db }
  end
  
  verify 'default MAX_CHARS is 30' do
    ARSettings.create_settings_class :Setting4
    assert_equal 30 , Setting4.MAX_CHARS
  end
  
  # leave it up to the user to ensure they are not speciying more than their DB's string class
  # if that is the case, they could switch it out with text
  verify 'can specify MAX_CHARS' do
    ARSettings.create_settings_class :Setting5 , :max_chars => 50
    assert_equal 50 , Setting5.MAX_CHARS
  end
  
end
