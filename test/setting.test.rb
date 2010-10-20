require File.dirname(__FILE__) + '/_helper'

class SettingTest < Test::Unit::TestCase
      
  def setup
    Setting.reset
    Setting.default = :the_default_value
  end
  
  verify 'can query whether a setting exists with setting?, and can declare settings with add_setting' do
    assert !Setting.setting?(:a)
    Setting.add_setting :a
    assert Setting.setting?(:a)
  end
  
  verify 'defaults to Setting.default if no default is given' do
    Setting.add_setting :a
    assert_equal :the_default_value , Setting.a
  end
  
  verify 'can add default when creating' do
    Setting.add_setting :a , :default => 123
    assert_equal 123 , Setting.a
  end
  
  verify 'can pass proc to handle postprocessing' do
    Setting.add_setting :a , :default => '123' do |setting|
      setting.to_i
    end
    assert_equal 123 , Setting.a
    Setting.a = '456'
    assert_equal 456 , Setting.a
  end
  
  verify 'adds record to the db' do
    assert_count 0
    Setting.add_setting :a , :default => /abc/
    assert_count 1
    setting = Setting.find_by_sql("select * from settings").first
    assert_equal 'a' , setting.name
    assert_equal( /abc/ , setting.value )
  end
  
  verify 'does not raise error if the setting already exists' do
    assert_nothing_raised { Setting.add_setting :a }
    assert_nothing_raised { Setting.add_setting :a }
  end
  
  verify 'does not overwrite current value with default when added repeatedly' do
    Setting.add_setting :a , :default => 12
    assert_equal 12 , Setting.a
    Setting.add_setting 'a' , :default => 13
    assert_equal 12 , Setting.a
    Setting.add_setting 'b' , :default => 14
    assert_equal 14 , Setting.b
    Setting.add_setting :b , :default => 15
    assert_equal 14 , Setting.b
  end
  
  
  verify 'get a list of settings' do
    Setting.add_setting :abc
    Setting.add_setting :def
    Setting.add_setting :ghi
    assert_equal [:abc,:def,:ghi] , Setting.settings.sort
  end
  
  verify 'get a list of settings and values' do
    Setting.add_setting :abc , :default => 1
    Setting.add_setting :def , :default => 2
    Setting.add_setting :ghi , :default => 3
    assert_equal [[:abc,1],[:def,2],[:ghi,3]] , Setting.settings_with_values.sort_by { |name,value| name }
  end
  
  verify 'can specify that object should reload from db each time' do
    Setting.add_setting :abcd , :default => 1
    Setting.add_setting :efgh , :default => 10 , :volatile => true
    assert_equal 1  , Setting.abcd
    assert_equal 10 , Setting.efgh
    $sql_executor.silent_execute "update settings set value='#{ARSettings.serialize(2)}' where name='abcd'"
    $sql_executor.silent_execute "update settings set value='#{ARSettings.serialize(20)}' where name='efgh'"
    assert_equal 1  , Setting.abcd
    assert_equal 20 , Setting.efgh
  end
  
  verify 'retains postprocessing after a reload' do
    Setting.add_setting( :abcd , :default => 1 , :volatile => true ) { |val| val.to_i }
    assert_equal 1 , Setting.abcd
    $sql_executor.silent_execute "update settings set value='#{ARSettings.serialize(2)}' where name='abcd'"
    assert_equal 2  , Setting.abcd
    Setting.abcd = "3"
    assert_equal 3 , Setting.abcd
  end
  
  verify 'readding the setting allows you to update volatility and postprocessing' do
    Setting.add_setting( :abcd , :default => "12.5" , :volatile => false ) { |val| val.to_f }
    assert_equal 12.5 , Setting.abcd
    $sql_executor.silent_execute "update settings set value='#{ARSettings.serialize(5.5)}' where name='abcd'"
    assert_equal 12.5 , Setting.abcd
    Setting.add_setting :abcd , :volatile => true
    assert_equal 5.5 , Setting.abcd
    Setting.add_setting( :abcd , :volatile => true ) { |val| val.to_i }
    assert_equal 5 , Setting.abcd
  end
  
  verify 'defaults get run through the postprocessor' do
    Setting.add_setting( :abcd , :default => "5" ) { |i| i.to_i }
    assert_equal 5 , Setting.abcd
  end
  
  verify 'raises NoSuchSettingError when invoking nonexistent setting' do
    assert_raises(Setting::NoSuchSettingError) { Setting.hjk     }
    assert_raises(Setting::NoSuchSettingError) { Setting.hjk = 1 }
  end
  
  verify 'can see constants' do
    assert_raises(Setting::NoSuchSettingError) { Setting.hjk }
    assert_raises(Setting.NoSuchSettingError)  { Setting.hjk }
  end
  
  verify 'raises InvalidSetting for settings with over MAX_NAME chars' do
    assert_nothing_raised { Setting.add_setting 'a' * Setting.MAX_CHARS      }
    assert_invalid_name   { Setting.add_setting 'a' * Setting.MAX_CHARS.next }
  end
  
end


