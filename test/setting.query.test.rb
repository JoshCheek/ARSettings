require File.dirname(__FILE__) + '/_helper'

# run the unit tests
class TestSettingQuery < Test::Unit::TestCase
      
  def setup
    Setting.delete_all
  end
  
  def assert_count(count)
    assert_equal count , Setting.count
  end
      
  verify "creates a setting when it doesn't exist" do
    assert_count 0
    Setting[:abc]
    assert_count 1
  end

  verify "doesn't create a setting when it exists" do
    assert_count 0
    Setting[:abc]
    assert_count 1
    Setting[:abc]
    assert_count 1
  end
  
  verify 'returns the value' do
    Setting[:abc] = 'a'
    assert_equal 'a' , Setting[:abc]
  end
  
  verify 'value has a default' do
    assert_equal Setting::DEFAULT , Setting[:abc]
    assert_equal 123 , Setting[ :xyz , 123 ]
  end
      
  verify 'returns the new value after the value has been changed' do
    Setting[:abc] = 1
    assert_equal 1 , Setting[:abc]
    Setting[:abc] = 2
    assert_equal 2 , Setting[:abc]
  end
  
  verify 'can take string or symbol' do
    Setting[:abc] =  12
    assert_equal     12 , Setting[ :abc  ]
    assert_equal     12 , Setting[ 'abc' ]
    Setting['xyz'] = 13
    assert_equal     13 , Setting[ :xyz  ]
    assert_equal     13 , Setting[ 'xyz' ]
  end
  
  verify 'raises InvalidName on non string or symbol' do
    object_menagerie.each do |object|
      next if object.kind_of?(String) || object.kind_of?(Symbol)
      assert_invalid_name { Setting[object] }
    end
  end
  
  verify 'raises error on string or symbol with over 30 chars' do
    assert_nothing_raised { Setting['aaaaaaaaaaaaaaaaaaaaaaaaaaaaaa' ] = '' }
    assert_nothing_raised { Setting[:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaa  ] = '' }
    assert_invalid_name   { Setting['aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'] = '' }
    assert_invalid_name   { Setting[:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa ] = '' }
  end
  
  verify 'queries from the db and not just saving in memory' do
    Setting[:abc] = 12
    setting = Setting.find_by_sql('SELECT * FROM settings').first
    setting.value = 13
    assert_equal 12 , Setting[:abc]
    setting.save
    assert_equal 13 , Setting[:abc]
  end

end
