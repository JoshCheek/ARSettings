require File.dirname(__FILE__) + '/_helper'

class TestScoping < Test::Unit::TestCase
  
  def get_class
    @class_numbers ||= Array(1..100)
    i = @class_numbers.shift
    Object.const_get "Model#{i}"
  end
  
  verify 'can add settings to any AR::B class with has_settings' do
    get_class.class_eval { has_settings }
  end
  
  verify 'default settings class is Setting' do
    klass = get_class
    klass.class_eval { has_settings }
    assert_equal Setting , klass.settings_class
  end
  
  verify 'can add settings after declaring that we have settings' do
    klass = get_class
    klass.class_eval do 
      has_settings
      add_setting :abcd , :default => 3
      add_setting :efgh , :default => 4
    end
    assert_equal 3 , klass.abcd
    assert_equal 4 , klass.efgh
  end

  verify 'can specify that a setting should be able to be looked up from the instance'
end




# probably a better way, but IDK what it is
# just adds a table and AR::B class for each test
ActiveRecord::Schema.define do
  suppress_messages do
    TestScoping.instance_methods.grep(/^test/).size.times do |i|
      create_table "model#{i+1}s" do |t|
        t.string  :name     , :null => false , :size => 30
        t.text    :value
        t.boolean :volatile , :default => false
        t.timestamps
      end
      Object.const_set "Model#{i+1}" , Class.new(ActiveRecord::Base)
    end    
  end
end
  
