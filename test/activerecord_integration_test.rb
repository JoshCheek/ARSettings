require File.dirname(__FILE__) + '/_helper'

class ActiveRecordIntegration < Test::Unit::TestCase
  
  def setup
    ARSettings.default_class = Setting
    Setting.reset_all
    @@class_numbers ||= Array(1..100)
    @klass = Object.const_get "Model#{@@class_numbers.shift}"
  end
  
  verify 'can add settings to any AR::B class with has_settings' do
    @klass.class_eval { has_setting :abcd , :default => 5 }
    assert_equal 5 , @klass.abcd
  end
  
  verify 'can specify that a setting should be able to be looked up from the instance' do
    @klass.class_eval { has_setting :abcd , :default => 4 }
    assert_equal 4 , @klass.new.abcd
  end

  verify 'settings are loaded from the db, if they exist in the db' do
    $sql_executor.silent_execute "insert into settings (name,value,package,volatile) values ('abcd','#{ARSettings.serialize(12)}','#{@klass.name}','f')"
    Setting.send :load_from_db # to simulate initial conditions
    @klass.class_eval { has_setting :abcd }
    assert_equal 12 , @klass.abcd
  end

  verify 'uses ARSettings.default_class' do
    ARSettings.create_settings_class :Setting16
    ARSettings.default_class = Setting16
    @klass.class_eval { has_setting :abcd }
    @klass.abcd = 50
    assert_equal 1  , Setting16.count
    assert_equal 50 , Setting16.first.value
  end

  verify 'can pass all the same args that Setting.add can take' do
    @klass.class_eval do
      has_setting :abcd , :default => 12 , :volatile => true do |val|
        val.to_i
      end
      has_setting :efgh , :default => 13.0 , :volatile => false do |val|
        val.to_f
      end
      has_setting :ijkl
    end
    assert_equal 12                   ,  @klass.abcd
    assert_equal 12.class             ,  @klass.abcd.class
    assert_equal 13.0                 ,  @klass.efgh
    assert_equal 13.0.class           ,  @klass.efgh.class
    assert_equal Setting::DEFAULT     ,  @klass.ijkl
    @klass.abcd = @klass.efgh = @klass.ijkl = '14'
    assert_equal 14                   ,  @klass.abcd
    assert_equal 14.class             ,  @klass.abcd.class
    assert_equal 14.0                 ,  @klass.efgh
    assert_equal 14.0.class           ,  @klass.efgh.class
    assert_equal '14'                 ,  @klass.ijkl
    assert_equal '14'.class           ,  @klass.ijkl.class
    $sql_executor.silent_execute "update settings set value='#{ARSettings.serialize(200)  }' where name='abcd'"
    $sql_executor.silent_execute "update settings set value='#{ARSettings.serialize(200.0)}' where name='efgh'"
    $sql_executor.silent_execute "update settings set value='#{ARSettings.serialize(200.0)}' where name='ijkl'"
    assert_equal 200                  ,  @klass.abcd
    assert_equal 14.0                 ,  @klass.efgh
    assert_equal '14'                 ,  @klass.ijkl
  end

  verify 'two classes dont see eachothers settings' do
    @klass1 = @klass
    setup
    @klass2 = @klass
    @klass1.class_eval { has_setting :abcd }
    @klass2.class_eval { has_setting :abcd }
    @klass1.abcd = 5
    @klass2.abcd = 6
    assert_equal 5 , @klass1.abcd
    assert_equal 6 , @klass2.abcd
  end

  verify 'updates setting values if readding' do
    @klass.class_eval { has_setting :abcd , :volatile => true , &lambda { |val| val.to_i * 2 } }
    @klass.abcd = 5
    assert_equal 10 , @klass.abcd
    $sql_executor.silent_execute "update settings set value='#{ARSettings.serialize(200)}' where name='abcd'"
    assert_equal 200 , @klass.abcd
    assert_equal 200 , @klass.abcd
    @klass.class_eval { has_setting :abcd , :volatile => false , &lambda { |val| val * 3 } }
    @klass.abcd = 5
    assert_equal 15 , @klass.abcd
    $sql_executor.silent_execute "update settings set value='#{ARSettings.serialize(200)}' where name='abcd'"
    assert_equal 15 , @klass.abcd
  end
  
end



# probably a better way, but IDK what it is
# just adds a table and AR::B class for each test
# and additional ones as necessary
ActiveRecord::Schema.define do
  suppress_messages do
    ActiveRecordIntegration.instance_methods.grep(/^test/).size.next.times do |i|
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
  
