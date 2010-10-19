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

end




# probably a better way, but IDK what it is
# just adds a table and AR::B class for each test
TestScoping.instance_methods.grep(/^test/).size.times do |i|
  
  ActiveRecord::Schema.define do
    create_table "model#{i+1}s" do |t|
      t.string  :name     , :null => false , :size => 30
      t.text    :value
      t.boolean :volatile , :default => false
      t.timestamps
    end
  end
  
  Object.const_set "Model#{i+1}" , Class.new(ActiveRecord::Base)
end