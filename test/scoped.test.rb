require File.dirname(__FILE__) + '/_helper'

# run the unit tests
class TestScoping < Test::Unit::TestCase
      
  def setup
    Setting.delete_all
    # @class = Class.new ActiveRecord::Base
  end
  
  verify 'can specify settings with hash' do
    # @class.class_eval do
    #   has_settings :abc => { :default => 5 , :type => :int }
    # end
    
  end

end
