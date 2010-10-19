require File.dirname(__FILE__) + '/_helper'

# run the unit tests
class DeclarationsTest < Test::Unit::TestCase
      
  def setup
    Setting.reset
  end
  
  verify 'can query whether a setting exists with setting?, and can declare settings with add_setting' do
    assert !Setting.setting?(:a)
    Setting.add_setting :a
    assert Setting.setting?(:a)
  end
  
  verify 'defaults to Setting.default if no default is given' do
    assert Setting
  end
    
end
