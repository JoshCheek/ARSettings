require File.dirname(__FILE__) + '/_helper'

# run the unit tests
class ResetTest < Test::Unit::TestCase
  
  def setup
    Setting.reset
    Setting.add_setting :abc
  end
  
  verify 'resets respond_to?' do
    assert Setting.respond_to?(:abc)
    Setting.reset
    assert !Setting.respond_to?(:abc)
  end
  
  verify 'resets method' do
    assert Setting.abc
    Setting.reset
    assert_raises(NoMethodError) { Setting.abc }
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
  
end
