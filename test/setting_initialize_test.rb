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
          
  verify 'loads up values previously stored in the db' do
    $sql_executor.silent_execute "insert into predefined_values (name,value,package,volatile) values ('predefined_value','#{ARSettings.serialize(12)}','PredefinedValues','f')"
    $sql_executor.silent_execute "insert into predefined_values (name,value,package,volatile) values ('predefined_value','#{ARSettings.serialize(13)}','String','f')"
    ARSettings.create_settings_class :PredefinedValues
    # make sure it loads the value
    assert_equal 2 , PredefinedValues.count
    assert PredefinedValues.package(PredefinedValues).setting?(:predefined_value)
    assert PredefinedValues.package(String).setting?(:predefined_value)
    assert_equal 12 , PredefinedValues.predefined_value
    assert_equal 13 , PredefinedValues.package(String).predefined_value
    PredefinedValues.add :predefined_value , :default => 20
    assert_equal 12 , PredefinedValues.predefined_value
  end
   
  verify 'can specify a volatility default' do
    ARSettings.create_settings_class :VolatileTest    , :volatile => true
    VolatileTest.add :abcd , :default => 1    , :volatile => false
    VolatileTest.add :efgh , :default => 10   , :volatile => true
    VolatileTest.add :ijkl , :default => 100
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
    begin
      flag = false
      Setting.load_from_db
      flag = true
    rescue Exception
      assert !flag
    end
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

  verify 'raises errors if values loaded from the db violate maxlength' do
    $sql_executor.silent_execute "insert into setting10s (name,value,package,volatile) values ('abc','#{ARSettings.serialize(12)}','Setting10','f')"
    assert_raises(ARSettings::InvalidNameError) { ARSettings.create_settings_class :Setting10 , :max_chars => 2 }
  end
  
  context 'ARSettings.default_class' do
    verify 'ARSettings will set the new class to the default if no default exists' do
      ARSettings.default_class = nil
      ARSettings.create_settings_class :Setting14s
      assert_equal Setting14s , ARSettings.default_class
    end
  end
  
  verify "doesn't raise error for valid options" do
    assert_nothing_raised do
      ARSettings.create_settings_class :Setting17s , :max_chars => 50 , :volatile => false
    end
  end
  
  verify "does raise error if it receives any invalid options" do
    [ [ :Setting18s  ,  :package         ,   String  ],
      [ :Setting19s  ,  :settings_class  ,   Setting ],
      [ :Setting20s  ,  :lkjdsf          ,   true    ],
      [ :Setting21s  ,  :abcd            ,   true    ],
      [ :Setting22s  ,  :instance        ,   true    ],
      [ :Setting24s  ,  :default         ,   true    ],
    ].each do |klass,key,value|
      assert_raises ARSettings::InvalidOptionError do
        ARSettings.create_settings_class klass , key => value
      end      
    end
  end
  
end
