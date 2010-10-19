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
ActiveRecord::Schema.define do
  create_table :settings do |t|
    t.string  :name  , :null => false , :size => 30
    t.text    :value
    t.timestamps
  end
end
$stdout = STDOUT
