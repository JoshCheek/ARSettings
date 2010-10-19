require File.dirname(__FILE__) + '/_helper'

# run the unit tests
class TestSettingQuery < Test::Unit::TestCase
      
  def setup
    Setting.delete_all
  end
  
  context 'validations' do
    verify 'does not allow duplicate names' do
      assert_count 0
      assert_nothing_raised { Setting.create! :name => 'n' , :value => 'v' }
      assert_count 1
      assert_invalid { Setting.create! :name => 'n' , :value => 'v2' }
      assert_count 1
    end
  end
  
end
