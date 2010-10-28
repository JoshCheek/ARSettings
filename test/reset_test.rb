require File.dirname(__FILE__) + '/_helper'

class ResetTest < Test::Unit::TestCase
  
  def setup
    Setting.package(String).reset
    Setting.package(String).add :abc
  end
  
  s = Setting.package(String)
  
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
  
  verify 'can reset all packages' do
    Setting.reset_all
    Setting.package(String).add :abcd
    Setting.package(Hash).add :efgh
    assert_equal 2 , Setting.count
    Setting.reset_all
    assert_equal 0 , Setting.count
  end
  
  verify "resetting one settings class' package doesn't impact others" do
    ARSettings.create_settings_class 'Setting6'
    Setting6.package(String).add :abc
    Setting6.package(Hash).add :def
    Setting.package(:ghi).add :jkl
    assert_equal 2 , Setting6.count
    assert_equal 2 , Setting.count
    Setting.reset_all
    assert_equal 2 , Setting6.count
    assert_equal 0 , Setting.count
    Setting.package(:ghi).add :mno
    Setting.package(:ghi).add :pqr
    Setting6.reset_all
    assert_equal 0 , Setting6.count
    assert_equal 2 , Setting.count
  end
  
  
end
