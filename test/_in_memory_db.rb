require 'rubygems'
require 'sqlite3'
require 'active_record'



# require the setting lib that we will be testing
require File.dirname(__FILE__) + '/../lib/arsettings'



# hook it up to an in memory sqlite3 db
ActiveRecord::Base.establish_connection :adapter => 'sqlite3' , :database => ":memory:" 



# silently create the db
require 'stringio'
old_stdout = $stdout
$stdout = StringIO.new

define_as_settings_class = lambda do |t|
  t.string  :name     , :null => false , :size => 30
  t.text    :value
  t.text    :package
  t.boolean :volatile , :default => false
  t.timestamps
end

ActiveRecord::Schema.define do
  
  [ 
    :different_names                  , 
    :predefined_values                ,
    :settings                         ,
    :setting2s                        ,
    :setting3s                        ,
    :setting4s                        ,
    :setting5s                        ,
    :setting6s                        ,
    :setting7s                        ,
    :setting8s                        ,
    :setting9s                        ,
    :setting10s                       ,
    :setting11s                       ,
    :setting12s                       ,
    :setting13s                       ,
    :setting14s                       ,
    :setting15s                       ,
    :setting16s                       ,
    :setting17s                       ,
    :setting18s                       ,
    :setting19s                       ,
    :setting20s                       ,
    :setting21s                       ,
    :setting22s                       ,
    :setting23s                       ,
    :setting24s                       ,
    :setting25s                       ,
    :volatile_tests                   ,
    :this_should_be_returneds         ,
  ].flatten.each do |tablename|
    create_table tablename , &define_as_settings_class
  end
  
  # capture this object so that I can write sql later (prob a better way, but IDK what it is)
  $sql_executor = self
  def $sql_executor.silent_execute(sql)
    suppress_messages { execute(sql) }
  end

end
$stdout = old_stdout
