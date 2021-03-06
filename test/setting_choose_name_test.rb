require File.dirname(__FILE__) + '/_helper'

class CanChooseNameOfSettingClass < Test::Unit::TestCase
  
  verify 'can choose name of the class to store settings in' do
    assert_raises(NameError) { DifferentName }
    ARSettings.create_settings_class 'DifferentName'
    assert_nothing_raised { DifferentName }
    assert_equal Class , DifferentName.class
    assert DifferentName.ancestors.include?(ActiveRecord::Base)
    assert_nothing_raised { DifferentName.add :abc , :default => 12 }
    assert_equal 12 , DifferentName.abc
  end
    
end
