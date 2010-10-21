require File.dirname(__FILE__) + '/_helper'

class TestScoping < Test::Unit::TestCase
  
  context 'singleton' do
    
    scoped = ARSettings::Scoped
    
    verify 'cannot instantiate on your own' do
      assert_raises(NoMethodError) { ARSettings::Scoped.new Setting , String }
    end
    
    verify 'has_instance? returns whether it has instantiated a given scope' do
      MyClass1 = Class.new
      assert !scoped.has_instance?(Setting,MyClass1)
      scoped.instance Setting , MyClass1
      assert scoped.has_instance?(Setting,MyClass1)
    end
    
    verify 'instance returns the same result' do
      scoped.instance(Setting,String)
      scoped.instance(Setting,String)
    end
    
    verify '#instance returns an instance of Scoped' do
      MyClass2 = Class.new
      assert_equal scoped , scoped.instance(Setting , MyClass2).class
      assert_equal scoped , scoped.instance(Setting , String).class
    end
    
    verify 'it raises an error if given a scope that is not a string / symbol / class' do
      assert_raises(ARSettings::InvalidScopeError) { scoped.instance(Setting,/whoops!/) }
      assert_nothing_raised { scoped.instance(Setting,'string')  }
      assert_nothing_raised { scoped.instance(Setting,:symbol)   }
      assert_nothing_raised { scoped.instance(Setting,Class)     }
    end
    
    verify 'raises error if settings_class is not a settings class' do
      assert_raises(scoped::InvalidSettingsClassError) { scoped.instance(String,String) }
    end

  end




  def setup
    Setting.scope(String).reset
    Setting.scope(String).default = :the_default_value
  end

  context 'settings behaviour' do

    s = Setting.scope(String)

    verify 'can query whether a setting exists with setting?, and can declare settings with add_setting' do
      assert !s.setting?(:a)
      s.add_setting :a
      assert s.setting?(:a)
    end

      # verify 'defaults to Setting.default if no default is given' do
      #   Setting.add_setting :a
      #   assert_equal :the_default_value , Setting.a
      # end
      
      # verify 'can add default when creating' do
      #   Setting.add_setting :a , :default => 123
      #   assert_equal 123 , Setting.a
      # end
      # 
      # verify 'can pass proc to handle postprocessing' do
      #   Setting.add_setting :a , :default => '123' do |setting|
      #     setting.to_i
      #   end
      #   assert_equal 123 , Setting.a
      #   Setting.a = '456'
      #   assert_equal 456 , Setting.a
      # end
      # 
      # verify 'adds record to the db' do
      #   assert_count 0
      #   Setting.add_setting :a , :default => /abc/
      #   assert_count 1
      #   setting = Setting.find_by_sql("select * from settings").first
      #   assert_equal 'a' , setting.name
      #   assert_equal( /abc/ , setting.value )
      # end
      # 
      # verify 'does not raise error if the setting already exists' do
      #   assert_nothing_raised { Setting.add_setting :a }
      #   assert_nothing_raised { Setting.add_setting :a }
      # end
      # 
      # verify 'does not overwrite current value with default when added repeatedly' do
      #   Setting.add_setting :a , :default => 12
      #   assert_equal 12 , Setting.a
      #   Setting.add_setting 'a' , :default => 13
      #   assert_equal 12 , Setting.a
      #   Setting.add_setting 'b' , :default => 14
      #   assert_equal 14 , Setting.b
      #   Setting.add_setting :b , :default => 15
      #   assert_equal 14 , Setting.b
      # end
      # 
      # 
      # verify 'get a list of settings' do
      #   Setting.add_setting :abc
      #   Setting.add_setting :def
      #   Setting.add_setting :ghi
      #   assert_equal [:abc,:def,:ghi] , Setting.settings.sort
      # end
      # 
      # verify 'get a list of settings and values' do
      #   Setting.add_setting :abc , :default => 1
      #   Setting.add_setting :def , :default => 2
      #   Setting.add_setting :ghi , :default => 3
      #   assert_equal [[:abc,1],[:def,2],[:ghi,3]] , Setting.settings_with_values.sort_by { |name,value| name }
      # end
      # 
      # verify 'can specify that object should reload from db each time' do
      #   Setting.add_setting :abcd , :default => 1
      #   Setting.add_setting :efgh , :default => 10 , :volatile => true
      #   assert_equal 1  , Setting.abcd
      #   assert_equal 10 , Setting.efgh
      #   $sql_executor.silent_execute "update settings set value='#{ARSettings.serialize(2)}' where name='abcd'"
      #   $sql_executor.silent_execute "update settings set value='#{ARSettings.serialize(20)}' where name='efgh'"
      #   assert_equal 1  , Setting.abcd
      #   assert_equal 20 , Setting.efgh
      # end
      # 
      # verify 'retains postprocessing after a reload' do
      #   Setting.add_setting( :abcd , :default => 1 , :volatile => true ) { |val| val.to_i }
      #   assert_equal 1 , Setting.abcd
      #   $sql_executor.silent_execute "update settings set value='#{ARSettings.serialize(2)}' where name='abcd'"
      #   assert_equal 2  , Setting.abcd
      #   Setting.abcd = "3"
      #   assert_equal 3 , Setting.abcd
      # end
      # 
      # verify 'readding the setting allows you to update volatility and postprocessing' do
      #   Setting.add_setting( :abcd , :default => "12.5" , :volatile => false ) { |val| val.to_f }
      #   assert_equal 12.5 , Setting.abcd
      #   $sql_executor.silent_execute "update settings set value='#{ARSettings.serialize(5.5)}' where name='abcd'"
      #   assert_equal 12.5 , Setting.abcd
      #   Setting.add_setting :abcd , :volatile => true
      #   assert_equal 5.5 , Setting.abcd
      #   Setting.add_setting( :abcd , :volatile => true ) { |val| val.to_i }
      #   assert_equal 5 , Setting.abcd
      # end
      # 
      # verify 'defaults get run through the postprocessor' do
      #   Setting.add_setting( :abcd , :default => "5" ) { |i| i.to_i }
      #   assert_equal 5 , Setting.abcd
      # end
      # 
      # verify 'raises NoSuchSettingError when invoking nonexistent setting' do
      #   assert_raises(Setting::NoSuchSettingError) { Setting.hjk     }
      #   assert_raises(Setting::NoSuchSettingError) { Setting.hjk = 1 }
      # end
      # 
      # verify 'can see constants' do
      #   assert_raises(Setting::NoSuchSettingError) { Setting.hjk }
      #   assert_raises(Setting.NoSuchSettingError)  { Setting.hjk }
      # end
      # 
      # verify 'raises InvalidSetting for settings with over MAX_NAME chars' do
      #   assert_nothing_raised { Setting.add_setting 'a' * Setting.MAX_CHARS      }
      #   assert_invalid_name   { Setting.add_setting 'a' * Setting.MAX_CHARS.next }
      # end
    
  end




#############################
  
  # verify 'it raises an error if given a bad name' do
  #   assert_raises(Setting::InvalidNameError) { scoped.instance(Setting,"a"*Setting::MAX_CHARS.next) }
  #   assert_raises(Setting::InvalidNameError) { scoped.instance(Setting,"a"*Setting::MAX_CHARS.next) }
  # end
  # verify 'settings classes can query for scoped settings' do
  #   Setting.add_setting :abcd , :scope => String , :default => 12
  #   assert_equal 12 , Setting.scoped_setting( String , :abcd )
  # end
  # 
  # verify 'can scope settings with classes' do
  #   setting = Setting.add_setting :abcd , :scope => String , :default => 12
  #   assert_equal :String , setting.current_scope
  # end
  # 
  # verify 'Setting.scope(scope) returns a ScopedSetting object' do
  #   assert_equal Setting::Scoped , Setting.scope(String).class
  # end
  # 
  # verify 'scoped knows its settings class' do
  #   assert_equal Setting , Setting.scope(String).settings_class
  # end
  # 
  # verify 'current_scope returns the current scope' do
  #   assert_equal :String , Setting.scope(String).current_scope
  #   assert_equal :string , Setting.scope('string').current_scope
  # end
  # 
  # verify 'default scope is the the symbol of the settings class itself' do
  #   assert_equal :Setting , Setting.current_scope
  # end
  # 
  # verify 'can use strings or symbols for scope as well' do
  #   assert_equal :abc , Setting.scope(:abc).current_scope
  #   assert_equal :abc , Setting.scope('abc').current_scope
  # end
  # 
  # verify 'raises error for non symbol/string/class' do
  #   assert_nothing_raised { Setting.scope("abc")            }
  #   assert_nothing_raised { Setting.scope(:abc)             }
  #   assert_nothing_raised { Setting.scope(Abc = Class.new)  }
  #   assert_raises(Setting::InvalidScopeError) { Setting.scope(1) }
  # end
  # 
  # verify 'can add and remove variables within a given scope' do
  #   Setting.add_setting :abcd , :scope => String , :default => 12
  #   string_settings = Setting.scope(String)
  #   assert_equal 12 , string_settings.abcd
  #   string_settings.abcd = 5
  #   assert_equal 5 , string_settings.abcd
  # end
  # 
  # verify 'raises NoSuchSettingError when given incorrect scope' do
  #   Setting.add_setting :abcd , :scope => String , :default => 12
  #   assert_raises(Setting::NoSuchSettingError) { Setting.abcd }
  #   assert_raises(Setting::NoSuchSettingError) { Setting.abcd = 3 }
  #   assert_nothing_raised { Setting.scope(String).abcd }
  #   assert_nothing_raised { Setting.scope(String).abcd = 5 }
  # end
  # 
  # verify 'scoped settings can list all settings and values'
  # verify 'reset only applies to settings of a given scope'
  
end

