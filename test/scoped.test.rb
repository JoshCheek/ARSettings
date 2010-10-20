require File.dirname(__FILE__) + '/_helper'

class TestScoping < Test::Unit::TestCase

  verify 'settings classes can query for scoped settings' do
    Setting.add_setting :abcd , :scope => String , :default => 12
    assert_equal 12 , Setting.scoped_setting( String , :abcd )
  end
  
  verify 'can scope settings with classes' do
    setting = Setting.add_setting :abcd , :scope => String , :default => 12
    assert_equal :String , setting.current_scope
  end
  
  verify 'Setting.scope(scope) returns a ScopedSetting object' do
    assert_equal Setting::Scoped , Setting.scope(String).class
  end
  
  verify 'scoped knows its settings class' do
    assert_equal Setting , Setting.scope(String).settings_class
  end
  
  verify 'current_scope returns the current scope' do
    assert_equal :String , Setting.scope(String).current_scope
    assert_equal :string , Setting.scope('string').current_scope
  end
  
  verify 'default scope is the the symbol of the settings class itself' do
    assert_equal :Setting , Setting.current_scope
  end
  
  verify 'can use strings or symbols for scope as well' do
    assert_equal :abc , Setting.scope(:abc).current_scope
    assert_equal :abc , Setting.scope('abc').current_scope
  end
  
  verify 'raises error for non symbol/string/class' do
    assert_nothing_raised { Setting.scope("abc")            }
    assert_nothing_raised { Setting.scope(:abc)             }
    assert_nothing_raised { Setting.scope(Abc = Class.new)  }
    assert_raises(Setting::InvalidScopeError) { Setting.scope(1) }
  end
  
  verify 'can add and remove variables within a given scope' do
    Setting.add_setting :abcd , :scope => String , :default => 12
    string_settings = Setting.scope(String)
    assert_equal 12 , string_settings.abcd
    string_settings.abcd = 5
    assert_equal 5 , string_settings.abcd
  end
  
  verify 'raises NoSuchSettingError when given incorrect scope' do
    Setting.add_setting :abcd , :scope => String , :default => 12
    assert_raises(Setting::NoSuchSettingError) { Setting.abcd }
    assert_raises(Setting::NoSuchSettingError) { Setting.abcd = 3 }
    assert_nothing_raised { Setting.scope(String).abcd }
    assert_nothing_raised { Setting.scope(String).abcd = 5 }
  end
  
  verify 'scoped settings can list all settings and values'
  verify 'reset only applies to settings of a given scope'
  
end

