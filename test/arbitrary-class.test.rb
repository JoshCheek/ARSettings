require File.dirname(__FILE__) + '/_helper'

class AddToArbitraryClass < Test::Unit::TestCase
      
  def setup
    Setting.reset_all
    Setting.default = :the_default_value
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
  
end