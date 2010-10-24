require File.dirname(__FILE__) + '/_helper'

class TestScoping < Test::Unit::TestCase
  
  def setup
    Setting.reset_all
    Setting.scope(String).default = :the_default_value
  end
  
  
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
    
    verify 'it considers strings, symbols, and classes to symbols' do
      assert_equal :cLaSs  , scoped.instance(Setting,'cLaSs').scope
      assert_equal :Symbol , scoped.instance(Setting,:Symbol).scope
      assert_equal :Symbol , scoped.instance(Setting,Symbol).scope
    end
    
    verify 'raises error if settings_class is not a settings class' do
      assert_raises(scoped::InvalidSettingsClassError) { scoped.instance(String,String) }
    end
  
    verify 'returns the same scope regardless of how it is requested' do
      id = Setting.scope(Setting).object_id
      assert_equal id , Setting.scope(:Setting).object_id
      assert_equal id , Setting.scope('Setting').object_id
    end
    
  end
  
  
  
  
  
  context 'settings behaviour' do
  
    s = Setting.scope(String)
  
    verify 'can query whether a setting exists with setting?, and can declare settings with add_setting' do
      assert !s.setting?(:a)
      s.add_setting :a
      assert s.setting?(:a)
    end
    
    verify "add_setting returns the setting's value" do
      assert_equal 1 , s.add_setting( :xyz , :default => 1)
      assert_equal 1 , s.add_setting( :xyz , :default => 2)
    end
  
    verify 'defaults to Setting.default if no default is given' do
      s.add_setting :a
      assert_equal :the_default_value , s.a
    end
      
    verify 'can add default when creating' do
      s.add_setting :a , :default => 123
      assert_equal 123 , s.a
    end
      
    verify 'can pass proc to handle postprocessing' do
      s.add_setting :a , :default => '123' do |setting|
        setting.to_i
      end
      assert_equal 123 , s.a
      s.a = '456'
      assert_equal 456 , s.a
    end
      
    verify 'adds record to the db' do
      assert_count 0
      s.add_setting :a , :default => /abc/
      assert_count 1
      setting = Setting.find_by_sql("select * from settings").first
      assert_equal 'a' , setting.name
      assert_equal( /abc/ , setting.value )
    end
      
    verify 'does not raise error if the setting already exists' do
      assert_nothing_raised { s.add_setting :a }
      assert_nothing_raised { s.add_setting :a }
    end
      
    verify 'does not overwrite current value with default when added repeatedly' do
      s.add_setting :a , :default => 12
      assert_equal 12 , s.a
      s.add_setting 'a' , :default => 13
      assert_equal 12 , s.a
      s.add_setting 'b' , :default => 14
      assert_equal 14 , s.b
      s.add_setting :b , :default => 15
      assert_equal 14 , s.b
    end
      
    verify 'get a list of settings' do
      s.add_setting :abc
      s.add_setting :def
      s.add_setting :ghi
      assert_equal [:abc,:def,:ghi] , s.settings.sort
    end
      
    verify 'get a list of settings and values' do
      s.add_setting :abc , :default => 1
      s.add_setting :def , :default => 2
      s.add_setting :ghi , :default => 3
      assert_equal [[:abc,1],[:def,2],[:ghi,3]] , s.settings_with_values.sort_by { |name,value| name }
    end
      
    verify 'can specify that object should reload from db each time' do
      s.add_setting :abcd , :default => 1
      s.add_setting :efgh , :default => 10 , :volatile => true
      assert_equal 1  , s.abcd
      assert_equal 10 , s.efgh
      $sql_executor.silent_execute "update settings set value='#{ARSettings.serialize(2)}' where name='abcd'"
      $sql_executor.silent_execute "update settings set value='#{ARSettings.serialize(20)}' where name='efgh'"
      assert_equal 1  , s.abcd
      assert_equal 20 , s.efgh
    end
      
    verify 'retains postprocessing after a reload' do
      s.add_setting( :abcd , :default => 1 , :volatile => true ) { |val| val.to_i }
      assert_equal 1 , s.abcd
      $sql_executor.silent_execute "update settings set value='#{ARSettings.serialize(2)}' where name='abcd'"
      assert_equal 2  , s.abcd
      s.abcd = "3"
      assert_equal 3 , s.abcd
    end
      
    verify 'readding the setting allows you to update volatility and postprocessing' do
      s.add_setting( :abcd , :default => "12.5" , :volatile => false ) { |val| val.to_f }
      assert_equal 12.5 , s.abcd
      $sql_executor.silent_execute "update settings set value='#{ARSettings.serialize(5.5)}' where name='abcd'"
      assert_equal 12.5 , s.abcd
      s.add_setting :abcd , :volatile => true
      assert_equal 5.5 , s.abcd
      s.add_setting( :abcd , :volatile => true ) { |val| val.to_i }
      assert_equal 5 , s.abcd
    end
      
    verify 'defaults get run through the postprocessor' do
      s.add_setting( :abcd , :default => "5" ) { |i| i.to_i }
      assert_equal 5 , s.abcd
    end
      
    verify 'raises NoSuchSettingError when invoking nonexistent setting' do
      assert_raises(ARSettings::NoSuchSettingError) { s.hjk     }
      assert_raises(ARSettings::NoSuchSettingError) { s.hjk = 1 }
    end
    
    verify 'raises InvalidSetting for settings with over MAX_NAME chars' do
      assert_nothing_raised { s.add_setting 'a' * s.settings_class.MAX_CHARS      }
      assert_invalid_name   { s.add_setting 'a' * s.settings_class.MAX_CHARS.next }
    end
        
  end





  

  context 'initializations' do
    
    s = Setting.scope(String)
    scoped = ARSettings::Scoped
    
    verify 'it raises an error if given a scope that is not string / symbol / class' do
      assert_nothing_raised { Setting.scope "string" }
      assert_nothing_raised { Setting.scope :Symbol  }
      assert_nothing_raised { Setting.scope Class    }
      assert_raises(ARSettings::InvalidScopeError) { Setting.scope 1 }
      assert_raises(ARSettings::InvalidScopeError) { Setting.scope Object.new }
      assert_raises(ARSettings::InvalidScopeError) { Setting.scope(SomeConstant=Object.new) }
    end
    
    verify 'can add a scope as an option' do
      Setting.add_setting :abcd , :scope => Hash , :default => 12
      assert_equal 12 , Setting.scope(Hash).abcd
      assert_raises(ARSettings::NoSuchSettingError) { Setting.abcd }
    end
    
    verify 'can scope settings with classes' do
      Setting.add_setting :abcd , :scope => String , :default => 12
      assert_equal 12 , s.abcd
      assert_equal :String , Setting.find( :first , :conditions => { :name => 'abcd' } ).scope
    end
  
    verify 'Setting.scope(scope) returns a ScopedSetting object' do
      assert_equal ARSettings::Scoped , Setting.scope(String).class
    end
  
    verify 'scoped knows its settings class' do
      assert_equal Setting , Setting.scope(String).settings_class
    end
  
    verify 'current_scope returns the current scope' do
      assert_equal :String , Setting.scope(String).scope
      assert_equal :string , Setting.scope('string').scope
      assert_equal :strIng , Setting.scope(:strIng).scope
    end
    
  
    verify 'can add and remove variables within a given scope' do
      s.add_setting :abcd , :default => 12
      assert_equal 12 , s.abcd
      s.abcd = 5
      assert_equal 5 , s.abcd
    end
  
    verify 'raises NoSuchSettingError when given incorrect scope' do
      s.add_setting :abcd , :default => 12
      assert_raises(ARSettings::NoSuchSettingError) { Setting.abcd }
      assert_raises(ARSettings::NoSuchSettingError) { Setting.abcd = 3 }
      assert_nothing_raised { s.abcd }
      assert_nothing_raised { s.abcd = 5 }
    end
  
    verify 'scoped settings can list all settings and values' do
      s.add_setting :abcd , :default => 1
      s.add_setting :efgh , :default => 2
      s.add_setting :ijkl , :default => 3
      assert_equal [:abcd,:efgh,:ijkl] , s.settings.sort 
      assert_equal [[:abcd,1],[:efgh,2],[:ijkl,3]] , s.settings_with_values.sort_by { |setting,value| value }
    end
    
    verify 'reset only applies to settings of a given scope' do
      string = Setting.scope(String)
      hash   = Setting.scope(Hash)
      string.add_setting :abcd , :default => 1
      hash.add_setting :abcd   , :default => 2
      string.reset
      assert_equal 1 , Setting.count
      assert_equal :Hash , Setting.first.scope
      assert_equal 2 , hash.abcd
    end
    
  end
  
  
end

