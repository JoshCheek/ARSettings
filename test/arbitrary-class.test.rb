require File.dirname(__FILE__) + '/_helper'

class AddToArbitraryClass < Test::Unit::TestCase
      
  def setup
    Setting.reset_all
    Setting.default = :the_default_value
  end
  
  def teardown
    ARSettings.default_class = Setting
  end
  
  def make_class(name,&block)
    self.class.const_set name , Class.new
    klass = self.class.const_get name
    ARSettings.on klass
    klass.instance_eval &block if block
  end
  
  verify 'can add to any class' do
    class C1 ; end
    assert_raises(NoMethodError) { C1.has_setting :abc }
    class C1 ; ARSettings.on self ; end
    assert_nothing_raised { C1.has_setting :abc }
  end
  
  verify 'this allows them to have settings' do
    make_class(:C2) { has_setting :abcd }
    C2.abcd = 5
    assert_equal 5 , C2.abcd
  end
    
  verify 'can specify the desired settings class when adding to another class' do
    ARSettings.create_settings_class :Setting12s
    class C4 ; ARSettings.on self , :settings_class => Setting12s ; end
    assert_equal 0 , Setting12s.count
    C4.has_setting :abcd
    assert_equal 1 , Setting12s.count
  end
  
  verify 'settings are loaded from the db, if they exist in the db' do
    $sql_executor.silent_execute "insert into settings (name,value,scope,volatile) values ('abcd','#{ARSettings.serialize(12)}','AddToArbitraryClass::C3','f')"
    Setting.send :load_from_db # to simulate initial conditions
    make_class(:C3) { has_setting :abcd }
    assert_equal 12 , C3.abcd
  end
  
  verify 'can specify settings without specifying a settings class, then it defaults to ARSettings.default_class' do
    ARSettings.create_settings_class :Setting13
    ARSettings.default_class = Setting13
    make_class(:C4) { has_setting :abcd }
    C4.abcd = 12
    assert_equal 1  , Setting13.count
    assert_equal 12 , Setting13.first.value
  end
  
  verify 'raises error if try to add settings without specifying a settings class or default' do
    ARSettings.default_class = nil
    assert_raises(ARSettings::NoDefaultScopeError) { make_class(:C5) { has_setting :abcd } }
  end
  
  verify 'can pass all the same args that Setting.add can take' do
    ARSettings.default_class = nil
    ARSettings.create_settings_class :Setting15
    make_class :C6 do
      has_setting :abcd , :default => 12 , :volatile => true do |val|
        val.to_i
      end
      has_setting :efgh , :default => 13.0 , :volatile => false do |val|
        val.to_f
      end
      has_setting :ijkl
    end
    assert_equal 12                   ,  C6.abcd
    assert_equal 12.class             ,  C6.abcd.class
    assert_equal 13.0                 ,  C6.efgh
    assert_equal 13.0.class           ,  C6.efgh.class
    assert_equal Setting15::DEFAULT   ,  C6.ijkl
    C6.abcd = C6.efgh = C6.ijkl = '14'
    assert_equal 14                   ,  C6.abcd
    assert_equal 14.class             ,  C6.abcd.class
    assert_equal 14.0                 ,  C6.efgh
    assert_equal 14.0.class           ,  C6.efgh.class
    assert_equal '14'                 ,  C6.ijkl
    assert_equal '14'.class           ,  C6.ijkl.class
    $sql_executor.silent_execute "update setting15s set value='#{ARSettings.serialize(200)  }' where name='abcd'"
    $sql_executor.silent_execute "update setting15s set value='#{ARSettings.serialize(200.0)}' where name='efgh'"
    $sql_executor.silent_execute "update setting15s set value='#{ARSettings.serialize(200.0)}' where name='ijkl'"
    assert_equal 200                  ,  C6.abcd
    assert_equal 14.0                 ,  C6.efgh
    assert_equal '14'                 ,  C6.ijkl
  end
  
  verify 'two classes dont see eachothers settings' do
    make_class(:C7) { has_setting :abcd }
    make_class(:C8) { has_setting :abcd }
    C7.abcd = 5
    C8.abcd = 6
    assert_equal 5 , C7.abcd
    assert_equal 6 , C8.abcd
  end
end

    