require File.dirname(__FILE__) + '/_helper'

class TestPackaging < Test::Unit::TestCase
  
  def setup
    Setting.reset_all
  end
  
  
  context 'singleton' do
    
    packaged = ARSettings::Packaged
    
    verify 'cannot instantiate on your own' do
      assert_raises(NoMethodError) { ARSettings::Packaged.new Setting , String }
    end
    
    verify 'has_instance? returns whether it has instantiated a given package' do
      MyClass1 = Class.new
      assert !packaged.has_instance?(Setting,MyClass1)
      packaged.instance Setting , MyClass1
      assert packaged.has_instance?(Setting,MyClass1)
    end
    
    verify 'instance returns the same result' do
      packaged.instance(Setting,String)
      packaged.instance(Setting,String)
    end
    
    verify '#instance returns an instance of Packaged' do
      MyClass2 = Class.new
      assert_equal packaged , packaged.instance(Setting , MyClass2).class
      assert_equal packaged , packaged.instance(Setting , String).class
    end
    
    verify 'it raises an error if given a package that is not a string / symbol / class' do
      assert_raises(ARSettings::InvalidPackageError) { packaged.instance(Setting,/whoops!/) }
      assert_nothing_raised { packaged.instance(Setting,'string')  }
      assert_nothing_raised { packaged.instance(Setting,:symbol)   }
      assert_nothing_raised { packaged.instance(Setting,Class)     }
    end
    
    verify 'it considers strings, symbols, and classes to symbols' do
      assert_equal :cLaSs  , packaged.instance(Setting,'cLaSs').package
      assert_equal :Symbol , packaged.instance(Setting,:Symbol).package
      assert_equal :Symbol , packaged.instance(Setting,Symbol).package
    end
    
    verify 'raises error if settings_class is not a settings class' do
      assert_raises(packaged::InvalidSettingsClassError) { packaged.instance(String,String) }
    end
  
    verify 'returns the same package regardless of how it is requested' do
      id = Setting.package(Setting).object_id
      assert_equal id , Setting.package(:Setting).object_id
      assert_equal id , Setting.package('Setting').object_id
    end
    
  end
  
  
  
  
  
  context 'settings behaviour' do
  
    s = Setting.package(String)
  
    verify 'can query whether a setting exists with setting?, and can declare settings with add' do
      assert !s.setting?(:a)
      s.add :a
      assert s.setting?(:a)
    end
    
    verify "add returns the package the setting was added to" do
      assert_equal s , s.add( :xyz , :default => 1)
      assert_equal s , s.add( :xyz , :default => 2)
    end
        
    verify 'can add default when creating' do
      s.add :a , :default => 123
      assert_equal 123 , s.a
    end
      
    verify 'can pass proc to handle postprocessing' do
      s.add :a , :default => '123' do |setting|
        setting.to_i
      end
      assert_equal 123 , s.a
      s.a = '456'
      assert_equal 456 , s.a
    end
      
    verify 'adds record to the db' do
      assert_count 0
      s.add :a , :default => /abc/
      assert_count 1
      setting = Setting.find_by_sql("select * from settings").first
      assert_equal 'a' , setting.name
      assert_equal( /abc/ , setting.value )
    end
      
    verify 'does not raise error if the setting already exists' do
      assert_nothing_raised { s.add :a }
      assert_nothing_raised { s.add :a }
    end
      
    verify 'does not overwrite current value with default when added repeatedly' do
      s.add :a , :default => 12
      assert_equal 12 , s.a
      s.add 'a' , :default => 13
      assert_equal 12 , s.a
      s.add 'b' , :default => 14
      assert_equal 14 , s.b
      s.add :b , :default => 15
      assert_equal 14 , s.b
    end
      
    verify 'get a list of settings' do
      s.add :abc
      s.add :def
      s.add :ghi
      assert_equal [:abc,:def,:ghi] , s.settings.sort_by { |name| name.to_s }
    end
      
    verify 'get a list of settings and values' do
      s.add :abc , :default => 1
      s.add :def , :default => 2
      s.add :ghi , :default => 3
      assert_equal [[:abc,1],[:def,2],[:ghi,3]] , s.settings_with_values.sort_by { |name,value| name.to_s }
    end
      
    verify 'can specify that object should reload from db each time' do
      s.add :abcd , :default => 1
      s.add :efgh , :default => 10 , :volatile => true
      assert_equal 1  , s.abcd
      assert_equal 10 , s.efgh
      $sql_executor.silent_execute "update settings set value='#{ARSettings.serialize(2)}' where name='abcd'"
      $sql_executor.silent_execute "update settings set value='#{ARSettings.serialize(20)}' where name='efgh'"
      assert_equal 1  , s.abcd
      assert_equal 20 , s.efgh
    end
      
    verify 'retains postprocessing after a reload' do
      s.add( :abcd , :default => 1 , :volatile => true ) { |val| val.to_i }
      assert_equal 1 , s.abcd
      $sql_executor.silent_execute "update settings set value='#{ARSettings.serialize(2)}' where name='abcd'"
      assert_equal 2  , s.abcd
      s.abcd = "3"
      assert_equal 3 , s.abcd
    end
    
    verify 'readding the setting allows you to update volatility' do
      s.add( :abcd , :default => "12.5" , :volatile => false ) { |val| val.to_f }
      assert_equal 12.5 , s.abcd
      $sql_executor.silent_execute "update settings set value='#{ARSettings.serialize(5.5)}' where name='abcd'"
      assert_equal 12.5 , s.abcd
      s.add :abcd , :volatile => true
      assert_equal 5.5 , s.abcd
    end

    verify 'postprocessing only occurs when inserting the data' do
      s.add( :abcd , :default => "12.5" , :volatile => false ) { |val| val.to_f }
      assert_equal 12.5 , s.abcd
      s.add( :abcd ) { |val| val.to_i }    
      assert_equal 12.5 , s.abcd
    end

    verify 'readding the setting allows you to update postprocessing' do
      s.add( :abcd , :default => 0 ) { |val| val.to_f }
      s.abcd = "12.5"
      assert_equal 12.5 , s.abcd
      s.add( :abcd ) { |val| val.to_i }
      s.abcd = "12.5"
      assert_equal 12 , s.abcd
    end
      
    verify 'defaults get run through the postprocessor' do
      s.add( :abcd , :default => "5" ) { |i| i.to_i }
      assert_equal 5 , s.abcd
    end
      
    verify 'raises NoSuchSettingError when invoking nonexistent setting' do
      assert_raises(ARSettings::NoSuchSettingError) { s.hjk     }
      assert_raises(ARSettings::NoSuchSettingError) { s.hjk = 1 }
    end
    
    verify 'raises InvalidSetting for settings with over MAX_NAME chars' do
      assert_nothing_raised { s.add 'a' * s.settings_class.MAX_CHARS      }
      assert_invalid_name   { s.add 'a' * s.settings_class.MAX_CHARS.next }
    end
        
  end





  

  context 'initializations' do
    
    s = Setting.package(String)
    packaged = ARSettings::Packaged
    
    verify 'it raises an error if given a package that is not string / symbol / class' do
      assert_nothing_raised { Setting.package "string" }
      assert_nothing_raised { Setting.package :Symbol  }
      assert_nothing_raised { Setting.package Class    }
      assert_raises(ARSettings::InvalidPackageError) { Setting.package 1 }
      assert_raises(ARSettings::InvalidPackageError) { Setting.package Object.new }
      assert_raises(ARSettings::InvalidPackageError) { Setting.package(SomeConstant=Object.new) }
    end
    
    verify 'can add a package as an option' do
      Setting.add :abcd , :package => Hash , :default => 12
      assert_equal 12 , Setting.package(Hash).abcd
      assert_raises(ARSettings::NoSuchSettingError) { Setting.abcd }
    end
    
    verify 'can package settings with classes' do
      Setting.add :abcd , :package => String , :default => 12
      assert_equal 12 , s.abcd
      assert_equal :String , Setting.find( :first , :conditions => { :name => 'abcd' } ).package
    end
  
    verify 'Setting.package(package) returns a PackagedSetting object' do
      assert_equal ARSettings::Packaged , Setting.package(String).class
    end
  
    verify 'packaged knows its settings class' do
      assert_equal Setting , Setting.package(String).settings_class
    end
  
    verify 'current_package returns the current package' do
      assert_equal :String , Setting.package(String).package
      assert_equal :string , Setting.package('string').package
      assert_equal :strIng , Setting.package(:strIng).package
    end
    
  
    verify 'can add and remove variables within a given package' do
      s.add :abcd , :default => 12
      assert_equal 12 , s.abcd
      s.abcd = 5
      assert_equal 5 , s.abcd
    end
  
    verify 'raises NoSuchSettingError when given incorrect package' do
      s.add :abcd , :default => 12
      assert_raises(ARSettings::NoSuchSettingError) { Setting.abcd }
      assert_raises(ARSettings::NoSuchSettingError) { Setting.abcd = 3 }
      assert_nothing_raised { s.abcd }
      assert_nothing_raised { s.abcd = 5 }
    end
  
    verify 'packaged settings can list all settings and values' do
      s.add :abcd , :default => 1
      s.add :efgh , :default => 2
      s.add :ijkl , :default => 3
      assert_equal [:abcd,:efgh,:ijkl] , s.settings.sort_by { |setting| setting.to_s }
      assert_equal [[:abcd,1],[:efgh,2],[:ijkl,3]] , s.settings_with_values.sort_by { |setting,value| value }
    end
    
    verify 'reset only applies to settings of a given package' do
      string = Setting.package(String)
      hash   = Setting.package(Hash)
      string.add :abcd , :default => 1
      hash.add :abcd   , :default => 2
      string.reset
      assert_equal 1 , Setting.count
      assert_equal :Hash , Setting.first.package
      assert_equal 2 , hash.abcd
    end

    verify "doesn't raise error for valid options" do
      assert_nothing_raised do
        s.add :abcd , :default => 1 , :volatile => true do end
      end
    end
    
    verify "does raise error if it receives any invalid options" do
      [ [ :a  ,  :package         ,   String  ],
        [ :b  ,  :settings_class  ,   Setting ],
        [ :c  ,  :lkjdsf          ,   true    ],
        [ :d  ,  :abcd            ,   true    ],
        [ :e  ,  :instance        ,   true    ],
      ].each do |meth,key,value|
        assert_raises ARSettings::InvalidOptionError do
          s.add meth , key => value
        end      
      end
    end

  end
  
  
end

