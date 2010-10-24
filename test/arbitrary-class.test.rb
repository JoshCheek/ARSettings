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
    klass.instance_eval &block
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
  
end