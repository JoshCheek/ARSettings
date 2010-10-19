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
  
  verify 'raises error if the setting already exists' do
    assert_nothing_raised { Setting.add_setting :a }
    assert_raises(Setting::AlreadyDefinedError) { Setting.add_setting :a }
  end
  
  verify 'uses indifferent access' do
    assert_nothing_raised { Setting.add_setting :a }
    assert_raises(Setting::AlreadyDefinedError) { Setting.add_setting 'a' }
    assert_raises(Setting::AlreadyDefinedError) { Setting.add_setting :a }
    Setting.reset
    assert_nothing_raised { Setting.add_setting 'a' }
    assert_raises(Setting::AlreadyDefinedError) { Setting.add_setting 'a' }
    assert_raises(Setting::AlreadyDefinedError) { Setting.add_setting :a }
  end

  verify 'get a list of settings' do
    Setting.reset
    Setting.add_setting :abc
    Setting.add_setting :def
    Setting.add_setting :ghi
    assert_equal [:abc,:def,:ghi] , Setting.settings.sort
  end
  
  verify 'get a list of settings and values' do
    Setting.reset
    Setting.add_setting :abc , :default => 1
    Setting.add_setting :def , :default => 2
    Setting.add_setting :ghi , :default => 3
    assert_equal [[:abc,1],[:def,2],[:ghi,3]] , Setting.settings_with_values.sort_by { |name,value| name }
  end
  
end


