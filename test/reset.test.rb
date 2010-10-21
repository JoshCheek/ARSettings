require File.dirname(__FILE__) + '/_helper'

class ResetTest < Test::Unit::TestCase
  
  def setup
    Setting.scope(String).reset
    Setting.scope(String).add_setting :abc
  end
  
  s = Setting.scope(String)
  
  verify 'resets respond_to?' do
    assert s.respond_to?(:abc)
    assert s.respond_to?(:abc=)
    s.reset
    assert !s.respond_to?(:abc)
    assert !s.respond_to?(:abc=)
  end
  
  verify 'resets method' do
    assert_nothing_raised { s.abc     }
    assert_nothing_raised { s.abc = 1 }
    s.reset
    assert_raises(ARSettings::NoSuchSettingError) { s.abc     }
    assert_raises(ARSettings::NoSuchSettingError) { s.abc = 2 }
  end
  
  verify 'resets setting?' do
    assert s.setting?(:abc)
    s.reset
    assert !s.setting?(:abc)
  end

  verify 'resets count' do
    assert_count 1
    s.reset
    assert_count 0
  end

  verify 'resets default' do
    s.default = 12
    assert_equal 12 , s.default
    s.reset
    assert_equal nil , s.default
  end
  
  
  
end
