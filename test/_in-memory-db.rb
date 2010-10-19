require 'rubygems'
require 'sqlite3'
require 'active_record'



# require the setting lib that we will be testing
require File.dirname(__FILE__) + '/../lib/arsettings'



# hook it up to an in memory sqlite3 db
ActiveRecord::Base.establish_connection :adapter => 'sqlite3' , :database => ":memory:" 



# silently create the db
require 'stringio'
$stdout = StringIO.new

define_as_settings_class = lambda do |t|
  t.string  :name            ,  :null => false , :size => 30
  t.text    :value
  t.text    :postprocessing
  t.timestamps
end

ActiveRecord::Schema.define do
  
  [ 
    :different_names      , 
    :predefined_values    ,
    :settings             ,
    :setting2s            ,
    :setting3s            ,
  ].each do |tablename|
    create_table tablename , &define_as_settings_class
  end
  
  execute "insert into predefined_values (name,value,postprocessing) values ('predefined_value','#{ARSettings.serialize(12)}','#{ARSettings.serialize(lambda{|i|i.to_i})}')"
end
$stdout = STDOUT
