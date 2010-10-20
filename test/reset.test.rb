require File.dirname(__FILE__) + '/_helper'

class ResetTest < Test::Unit::TestCase
  
  def setup
    Setting.reset
    Setting.add_setting :abc
  end
  
  verify 'resets respond_to?' do
    assert Setting.respond_to?(:abc)
    assert Setting.respond_to?(:abc=)
    Setting.reset
    assert !Setting.respond_to?(:abc)
    assert !Setting.respond_to?(:abc=)
  end
  
  verify 'resets method' do
    assert_nothing_raised { Setting.abc     }
    assert_nothing_raised { Setting.abc = 1 }
    Setting.reset
    assert_raises(Setting::NoSuchSettingError) { Setting.abc     }
    assert_raises(Setting::NoSuchSettingError) { Setting.abc = 2 }
  end
  
  verify 'resets setting?' do
    assert Setting.setting?(:abc)
    Setting.reset
    assert !Setting.setting?(:abc)
  end

  verify 'resets count' do
    assert_count 1
    Setting.reset
    assert_count 0
  end

  verify 'resets default' do
    Setting.default = 12
    assert_equal 12 , Setting.default
    Setting.reset
    assert_equal nil , Setting.default
  end
  
end
