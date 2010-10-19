require File.dirname(__FILE__) + '/_helper'

# run the unit tests
class TestChooseName < Test::Unit::TestCase
  
  context 'validations' do
    verify 'does not allow duplicate names' do
      assert_raises(NameError) { DifferentName }
      ARSettings.settings_class = 'DifferentName'
      assert_nothing_raised { DifferentName }
    end
  end
  
end
