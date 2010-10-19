require File.dirname(__FILE__) + '/_helper'

# run the unit tests
class TestSettingSet < Test::Unit::TestCase
      
  def setup
    Setting.delete_all
  end
  
  verify "creates a new setting when one doesn't exist" do
    assert_count 0
    Setting[:abc] = 1
    assert_count 1
  end
  
  verify 'changes the value of the setting' do
    Setting[:abc] = '1'
    assert_equal '1' , Setting[:abc]
    Setting[:abc] = '2'
    assert_equal '2' , Setting[:abc]
  end
  
  verify 'raises error on name with over 30 chars' do
    assert_nothing_raised { Setting['aaaaaaaaaaaaaaaaaaaaaaaaaaaaaa' ] = '' }
    assert_nothing_raised { Setting[:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaa  ] = '' }
    assert_invalid_name   { Setting['aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'] = '' }
    assert_invalid_name   { Setting[:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa ] = '' }
  end
  
  verify 'assert raises error on name that is not string or symbol' do
    assert_nothing_raised { Setting[ 'a' ] = '' }
    assert_nothing_raised { Setting[ :a  ] = '' }
    assert_invalid_name   { Setting[ /a/ ] = '' }
    assert_invalid_name   { Setting[ 0xa ] = '' }
  end
  
  verify 'can set value to be pretty much any type' do
    object_menagerie.each do |object|
      Setting[:serialize] = object
      assert_equal object , Setting[:serialize]
    end
  end

end
