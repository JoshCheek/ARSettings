require File.dirname(__FILE__) + '/_helper'

class SettingTest < Test::Unit::TestCase
      
  def setup
    Setting.reset_all
    Setting.default = :the_default_value
  end
  
  verify 'can query whether a setting exists with setting?, and can declare settings with add' do
    assert !Setting.setting?(:a)
    Setting.add :a
    assert Setting.setting?(:a)
  end
  
  verify 'defaults to Setting.default if no default is given' do
    Setting.add :a
    assert_equal :the_default_value , Setting.a
  end
  
  verify 'can add default when creating' do
    Setting.add :a , :default => 123
    assert_equal 123 , Setting.a
  end
  
  verify 'can pass proc to handle postprocessing' do
    Setting.add :a , :default => '123' do |setting|
      setting.to_i
    end
    assert_equal 123 , Setting.a
    Setting.a = '456'
    assert_equal 456 , Setting.a
  end
  
  verify 'adds record to the db' do
    assert_count 0
    Setting.add :a , :default => /abc/
    assert_count 1
    setting = Setting.find_by_sql("select * from settings").first
    assert_equal 'a' , setting.name
    assert_equal( /abc/ , setting.value )
  end
  
  verify 'does not raise error if the setting already exists' do
    assert_nothing_raised { Setting.add :a }
    assert_nothing_raised { Setting.add :a }
  end
  
  verify 'does not overwrite current value with default when added repeatedly' do
    Setting.add :a , :default => 12
    assert_equal 12 , Setting.a
    Setting.add 'a' , :default => 13
    assert_equal 12 , Setting.a
    Setting.add 'b' , :default => 14
    assert_equal 14 , Setting.b
    Setting.add :b , :default => 15
    assert_equal 14 , Setting.b
  end
  
  
  verify 'get a list of settings' do
    Setting.add :abc
    Setting.add :def
    Setting.add :ghi
    assert_equal [:abc,:def,:ghi] , Setting.settings.sort_by { |name| name.to_s }
  end
  
  verify 'get a list of settings and values' do
    Setting.add :abc , :default => 1
    Setting.add :def , :default => 2
    Setting.add :ghi , :default => 3
    assert_equal [[:abc,1],[:def,2],[:ghi,3]] , Setting.settings_with_values.sort_by { |name,value| name.to_s }
  end
  
  verify 'can specify that object should reload from db each time' do
    Setting.add :abcd , :default => 1
    Setting.add :efgh , :default => 10 , :volatile => true
    assert_equal 1  , Setting.abcd
    assert_equal 10 , Setting.efgh
    $sql_executor.silent_execute "update settings set value='#{ARSettings.serialize(2)}' where name='abcd'"
    $sql_executor.silent_execute "update settings set value='#{ARSettings.serialize(20)}' where name='efgh'"
    assert_equal 1  , Setting.abcd
    assert_equal 20 , Setting.efgh
  end
  
  verify 'retains postprocessing after a reload' do
    Setting.add( :abcd , :default => 1 , :volatile => true ) { |val| val.to_i }
    assert_equal 1 , Setting.abcd
    $sql_executor.silent_execute "update settings set value='#{ARSettings.serialize(2)}' where name='abcd'"
    assert_equal 2  , Setting.abcd
    Setting.abcd = "3"
    assert_equal 3 , Setting.abcd
  end
  
  verify 'readding the setting allows you to update volatility and postprocessing' do
    Setting.add( :abcd , :default => "12.5" , :volatile => false ) { |val| val.to_f }
    assert_equal 12.5 , Setting.abcd
    $sql_executor.silent_execute "update settings set value='#{ARSettings.serialize(5.5)}' where name='abcd'"
    assert_equal 12.5 , Setting.abcd
    Setting.add :abcd , :volatile => true
    assert_equal 5.5 , Setting.abcd
    Setting.add( :abcd , :volatile => true ) { |val| val.to_i }
    assert_equal 5 , Setting.abcd
  end
  
  verify 'defaults get run through the postprocessor' do
    Setting.add( :abcd , :default => "5" ) { |i| i.to_i }
    assert_equal 5 , Setting.abcd
  end
  
  verify 'raises NoSuchSettingError when invoking nonexistent setting' do
    assert_raises(ARSettings::NoSuchSettingError) { Setting.hjk     }
    assert_raises(ARSettings::NoSuchSettingError) { Setting.hjk = 1 }
  end
  
  verify 'raises InvalidSetting for settings with over MAX_NAME chars' do
    assert_nothing_raised { Setting.add 'a' * Setting.MAX_CHARS      }
    assert_invalid_name   { Setting.add 'a' * Setting.MAX_CHARS.next }
  end
  
  verify 'raises Invalid name error if the setting is not a valid method name' do
    [ '123' , '1abc' , '.abc' , 'Constant' , 'ab-c' , 'ab.c' , 'ab)c' , 'ab@c' , 'a:b' ].each do |invalid_name|
      assert_invalid_name { Setting.add invalid_name }
    end
  end
  
  verify 'add returns the value of the setting' do
    assert_equal 100 , Setting.add( :a , :default => 100)
    assert_equal 101 , Setting.scope(String).add( :b , :default => 101)
    assert_equal 101 , Setting.scope(String).add( :b , :default => 102)
  end
  
end


